--[[  DataBridge  v5.0.0
      Author:     Allen Woods
                  @Raveshaper   -   reasontalk.slack.com
                                -   forums.reasontalk.com

      Foreword:   This project is available free of charge.
                  However, should you feel like donating, my PayPal link can be found
                  below.

      Donations:  paypal.me/raveshaper

      Desc:       DataBridge is a collection of control surfaces whose architecture has been
                  designed to operate as a unified, scalable, modular system that enables
                  real time dynamic modulations, advanced MIDI mappings, and unprecedented
                  live performance capabilities within Reason 7 or higher.

                  Thank you for using DataBridge, and enjoy!
  ]]

--[[  BEGIN: Virtual Inputs       ]]

_G["global_outputs"]								= 1     -- data network (global)
--[[  END: Virtual Output Counts  ]]

--[[  BEGIN: Virtual Layer Structure

      The virtual layer structure is an optional feature that enables each control surface
      to function in a similar manner to pages/scenes on more advanced MIDI controllers.

      MIDI controllers that provide page/scene functionality are not required to use this
      optional feature.

      The way this feature works in practice is that each control surface can be assigned
      a layer address that then acts like a key that effectively unlocks only the control
      surfaces that share a common layer address at any given time.

      The perceived result is the ability to reuse Control Change messages from MIDI hardware
      to access and manipulate multiple devices depending on the "layer" that is currently
      being accessed, for example.

      IMPORTANT:
        * Virtual layer count must be a positive integer equal to or greater than 1.
        * The recommended upper bound of this value is 8, however, you can build as much as
          your computer can run.
]]

_G["max_layer_count"]								= 8
--[[  END: Virtual Layer Structure  ]]

-- global name of the current device type, for use with warp function
_G["device_type"] = nil

-- global copy of names table; this is used by the command line editor to edit specific items
_G["g_names"] = nil


--[[  Define User Interface ]]

ui = {                          --  User Interface
  "b0 5e xx",                       --  CC 94:  Panic                       implemented
  "b0 5f xx",                       --  CC 95:  Relative                    implemented
  "b0 60 xx",                       --  CC 96:  Physics/Inertia             legacy (not currently used)
  "b0 61 xx",                       --  CC 97:  Curve Type                  implemented
  "b0 62 xx",                       --  CC 98:  Step Amount of Curve        implemented
  "b0 63 xx",                       --  CC 99:  Navigate Layers             implemented
  "b0 64 xx",                       --  CC100:  Edit Min                    implemented
  "b0 65 xx",                       --  CC101:  Edit Max                    implemented
  0,0,0,0,                          --  Latches
  0,0,0,0,
  false,false,                      --  States
  false,false,
  false,false,
  false,false
}

--[[  Important globals           ]]
reason_document = false             --  the script uses this to respond uniquely to document scope
midi_rat        = 1 / 127           --  folded constant for ratios mased on midi values
midi_controller = false             --  the script uses this to respond to midi events
midi_channel    = "?"               --  respond to all midi channels by default
bind_to_ly      = false             --  boolean flag that tells this surface whether it is bound to a virtual layer
ly_address      = nil               --  integer value pointing to the address of the virtual layer for this surface
ly_selected     = nil               --  boolean flag that tells this surface what virtual layer is selected within the global system architecure
deck_number			= nil               --  integer value describing the virtual deck for this surface (2 deck system on single midi port)
deck_clock			=	nil               --  integer value describing the clock channel for this virtual deck
clock_mask			=	nil               --  hexadecimal string that defines the pattern the system uses to look for clock data on this virtual deck
kb_enabled      = false             --  boolean flag that tells this surface whether it has master keyboard input
has_pitch_wheel = false             --  boolean flag for whether this device has a pitch wheel or not.
warp_from       = nil               --  integer value that defines the project tempo at the moment the warp engine feature is enabled
warp_from_bpm   = nil               --  dedicated integer value for the project tempo in bpm
warp_from_dec   = nil               --  dedicated integer value for the project tempo in beats, 16ths, and ticks
warp_enabled    = false             --  boolean flag that tells this surface the warp engine feature is enabled
last_warp_state = false             --  boolean flag that stores the previous state of warp_enabled to allow for intelligent decoupling
warp_use_24     = false             --  boolean flag that tells this surface to constrain the warp engine feature to 24 semitones
warp_24_rat = (1 / 24)              --  folded constant of the ratio for the 24 semitones
warp_ls 		= 8192               --  folded constant of the scalar value of the left side of the warp engine
warp_ls_rat = (1 / warp_ls)         --  folded constant of the ratio for the left side
warp_rs 		= 8191               --  folded constant of the scalar value of the right side of the warp engine
warp_rs_rat	= (1 / warp_rs)         --  folded constant of the ratio for the right side
i_count = nil                       --  integer value for the number of inputs (data sources/device controls)
o_count = nil                       --  integer value for the number of virtual outputs per input
def_min = {}                        --  table of default minimum values
def_max = {}                        --  table of default maximum values
def_dlt = {}                        --  table of default delta values (max - min)
noedit  = {}                        --  table of "true" boolean values for every data source that can not be edited, enabled items equal nil
min     = {}                        --  table of min values
max     = {}                        --  table of max values
dlt     = {}                        --  table of delta values (max - min)
mid     = {}                        --  table of midpoints ((max - min) * 0.5) + min
int     = {}                        --  table of values ranging from 1 to 128, pointing to the specific interpolation curve variation for this virtual output
step    = {}                        --  table of values ranging from 1 to 128, indicating how many steps it takes to plot the graph of int[]
rat     = {}                        --  table of the ratios for these items (inputs and outputs)
idx     = {}                        --  table of integer values that point to the index of the inputs and virtual outputs
odx     = {}                        --  table of integer values that point to the index of the input these virtual outputs are branched from (reverse lookup)
this		= {}                        --  a record of the current changes
last		= {}                        --  a record of the previous changes
min_ms  = 25                        --  BEGIN: variables used for the smooth response to endless rotary encoders
max_ms  = 175
this_ms = {}
last_ms = {}
dlt_ms  = {}
enc_dir = {}                        -- END: endless rotary encoders
g_batch = {}                        --  the batch of data that gets written to the rack using remote.handle_input()
--  midi controller specific vars
data_type  = {}                     --  a table of strings indicating the type of controls mapped to the given midi message(s), such as rotary encoders, button, and knob

--	special indexes
terminal_idx    = nil               --  the index of the Device Name input, for command line editor functionality
kb_idx					= nil               --  the index of the master keyboard
pitch_idx				= nil               --  the index of the Pitch Bend input, for use with the warp engine function
range_idx       = nil               --  the index of the Pitch Bend Range input, for use with the warp engine function
mod_idx					= nil               --  BEGIN: index values for the common global MIDI performance controllers (Mod, Channel Pressure, Expression, Damper, Breath)
pressure_idx		= nil
expression_idx	= nil
damper_idx			= nil
breath_idx			= nil               --  END: MIDI performance controllers
midi_max_val    = 127               --  the maximum midi value
out_data_max    = 4194048           --  the maximum value for unipolar data sent to virtual outputs
out_data_rat    = 1 / out_data_max  --  the ratio of the max data value for virtual outputs
entity_loaded   = false             --  boolean flag that tells this surface that its internal structure has been successfully initialized.

-- decimal to hex converter
-- written:	06/15/2016
function hex(dec)
	return string.format("%02x", dec)
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function build_terminal()
	--	might not need latch
	_G["this_terminal"] = nil
	_G["last_terminal"] = nil
	-- _G["terminal_latch"] = 0
	_G["sys_resume_state"] = nil
end

--[[	TERMINAL...

      reset function for terminal, must receive "true" boolean value to execute
      SYNTAX:

           _r(1)

      ARGUMENTS:
          b = 0 (false), 1 (true)
  ]]

function _r(b)
	if b==1 then
		--	store the state of the system
		sys_resume_state = ui[17]
		--	suspend user input
		ui[17]					= true
		sys_suspend			= true
		--	restore defaults
		restore_defaults()
    bind_to_ly = false
    ly_address = nil
    ly_selected = nil
    midi_channel = "?"
	end
end

-- default value restoration function
function restore_defaults()
	for d=1,#def_min do
		min[d] = def_min[d]
		max[d] = def_max[d]
    mid[d] = min[d] + ((max[d] - min[d]) * 0.5)
		dlt[d] = def_dlt[d]
    rat[d] = (1 / dlt[d])
	end
  for dt=1,#data_type do
    data_type[dt] = "abs"
  end
  if midi_controller then
    for t=1,#this do
      this[t] = 64
      last[t] = 64
    end
  else
    for i=1,#int do
      int[i] = 1
      step[i] = 127
    end
  end
	-- restore the functional state of the system prior to suspension
	if sys_resume_state==false then
		ui[17] = sys_resume_state
	end
	sys_suspend	= false
end

--[[  global editing function, applies inputs to entire device
      SYNTAX:

           _g(16,1,128,enc,128,128,127,127,127,127)

      ARGUMENTS:
          ch_n   :  1 to 16                 --  midi channel
          bind_b :  0 (false), 1 (true)     --  bind to a virtual layer
          ly_n   :  1 to n                  --  virtual layer address
          d_type :  "enc" (relative input for endless rotary encoder),  --  the data type of the midi input for this item
                    "abs" (fixed midi knob, 0 to 127)
          int_c  :  1 to 128                --  interpolation curve
          int_s  :  1 to 128                --  interpolation step

          NOTE: The following arguments act as ratios, where 0 = 0 and 127 = 1.
                The ratio yielded by the numeric argument is then multiplied by the
                data range of the item type (input, virtual output) and gives the final
                coarse grained data value desired.

          i_min  :  0 to 127                --  input item min val
          i_max  :  0 to 127                --  input item max val
          o_min  :  0 to 127                --  virtual output min val
          o_max  :  0 to 127                --  virtual output max val
  ]]

function _g(ch_n,bind_b,ly_n,d_type,int_c,int_s,i_min,i_max,o_min,o_max)
	local io_n = i_count * o_count
	if ch_n~=nil and ch_n > 0 and ch_n < 17 then
		midi_channel = string.sub(hex(ch_n-1), -1)
	end
	if bind_b~=nil then
		if bind_b==1 then
			bind_to_ly = true
      ly_selected = 1
			if ly_n~=nil then
				if ly_n >= 1 and ly_n <= max_layer_count then
					ly_address = ly_n
				end
      else
        -- assign layer 1 if none provided
        ly_address = 1
			end
		elseif bind_b==0 then
			bind_to_ly = false
		end
	end
  if ly_n~=nil then
		if ly_n >= 1 and ly_n <= max_layer_count then
			ly_address = ly_n
		end
  else
    ly_address = nil
    ly_selected = nil
	end
	if d_type~=nil then
		if d_type=="enc" or d_type=="abs" then
			for d=1,#data_type do
				data_type[d] = d_type
			end
		end
	end
	if i_min~=nil then
		local i_min_fmt = tonumber(i_min)
		if type(i_min_fmt)=="number" then
			for i=1,i_count do
        if g_names[i]~="Keyboard" then
  				-- we assign the default minimum plus the percentage of the default delta value given by the multiplicand of i_min.
  				min[io_n+3+i] = (i_min_fmt*midi_rat) * def_dlt[io_n+3+i]
          dlt[io_n+3+i] = max[io_n+3+i] - min[io_n+3+i]
          rat[io_n+3+i] = (1 / dlt[io_n+3+i])
        end
			end
		end
	end
	if i_max~=nil then
		local i_max_fmt = tonumber(i_max)
		if type(i_max_fmt)=="number" and g_names[i]~="Keyboard" then
			for i=1,i_count do
        if g_names[i]~="Keyboard" then
  				max[io_n+3+i] = (i_max_fmt*midi_rat) * def_dlt[io_n+3+i]
          dlt[io_n+3+i] = max[io_n+3+i] - min[io_n+3+i]
          rat[io_n+3+i] = (1 / dlt[io_n+3+i])
        end
			end
		end
	end
  if int_c~=nil then
    if int_c >= 1 and int_c <= midi_max_val+1 then
      for o=1,io_n do
        int[o] = int_c
      end
    end
  end
  if int_s~=nil then
    if int_s >= 1 and int_s <= midi_max_val+1 then
      for o=1,io_n do
        step[o] = int_s
      end
    end
  end
  if o_min~=nil then
    local o_min_fmt = tonumber(o_min)
    if type(o_min_fmt)=="number" then
      for o=1,io_n do
        min[o] = (o_min_fmt*midi_rat) * def_dlt[o]
        dlt[o] = max[o] - min[o]
        rat[o] = (1 / dlt[o])
      end
    end
  end
  if o_max~=nil then
    local o_max_fmt = tonumber(o_max)
    if type(o_max_fmt)=="number" then
      for o=1,io_n do
        max[o] = def_min[o] + (o_max_fmt*midi_rat) * def_dlt[o]
        dlt[o] = max[o] - min[o]
        rat[o] = (1 / dlt[o])
      end
    end
  end
end

--[[  parameter editing function, applies only to the parameters specified
      SYNTAX:

           _p("Target Track Enable Automation Recording","ov",128,127,127)

      LEGEND:
			     _p(<data src name>,<io type>,<arg 1>,<arg 2>,<arg 3>)
      ARGUMENTS:
    			data src name : string, the data source to edit
    			io type : string, defines a two character code for the data source or output and its editing mode
    									char 1 = "s" : select the source to edit
    									char 1 = "o" : select an output to edit

    									char 2 = "v" : select min and max values to edit
    									char 2 = "i" : select curve and step to edit
    									char 2 = "t" : select abs/enc data type to edit
    			arg 1 : edits min val (src) / selects output number
    			arg 2 : edits max val (src) / edits min val (out) / curve / data type (abs or enc)
    			arg 3 : edits max val (out) / step
  ]]

function _p(d_src,io_type,arg_1,arg_2,arg_3)
  local io_n = i_count * o_count
  local o_n = o_count
  local n_c = 3
	if d_src~=nil then
		if type(d_src)=="string" then
			local io_n = i_count * o_count
			local io_idx = nil
			for i,v in ipairs(g_names) do
				if v==d_src then
					io_idx = i
					break
				end
			end
      if midi_controller then
        n_c = 0
        io_idx = io_idx~=nil and (io_idx - n_c) or nil
      end
			if io_idx~=nil then
				if io_type~=nil then
					if type(io_type)=="string" then
						if io_type:sub(1,1)=="s" then
							if io_type:sub(2,2)=="v" then
								if arg_1~=nil then
									if type(arg_1)=="number" then
										if arg_1 >= 0 and arg_1 <= midi_max_val then
											min[io_n+n_c+io_idx] = (arg_1 * midi_rat) * def_dlt[io_n+n_c+io_idx]
                      dlt[io_n+n_c+io_idx] = max[io_n+n_c+io_idx] - min[io_n+n_c+io_idx]
                      rat[io_n+n_c+io_idx] = (1 / dlt[io_n+n_c+io_idx])
										end
									end
								end
								if arg_2~=nil then
									if type(arg_2)=="number" then
										if arg_2 >= 0 and arg_2 <= midi_max_val then
                      max[io_n+n_c+io_idx] = (arg_2 * midi_rat) * def_dlt[io_n+n_c+io_idx]
                      dlt[io_n+n_c+io_idx] = max[io_n+n_c+io_idx] - min[io_n+n_c+io_idx]
                      rat[io_n+n_c+io_idx] = (1 / dlt[io_n+n_c+io_idx])
										end
									end
								end
							elseif io_type:sub(2,2)=="t" then
								if arg_1~=nil then
									if type(arg_1)=="string" then
										if arg_1=="abs" or arg_1=="enc" then
											data_type[io_n+n_c+io_idx] = arg_1
										end
									end
								end
							end
						elseif io_type:sub(1,1)=="o" then
							if arg_1~=nil then
								if type(arg_1)=="number" then
									if arg_1 >= 1 and arg_1 <= o_count then
										io_idx = ((io_idx - 1)*o_count) + arg_1
										if arg_2~=nil then
											if type(arg_2)=="number" then
												if io_type:sub(2,2)=="v" then
													if arg_2 >= 0 and arg_2 <= midi_max_val then
														min[io_idx] = (arg_2 * midi_rat) * def_dlt[io_idx]
                            dlt[io_idx] = max[io_idx] - min[io_idx]
                            rat[io_idx] = (1 / dlt[io_idx])
													end
												elseif io_type:sub(2,2)=="i" then
													if arg_2 >= 1 and arg_2 <= midi_max_val+1 then
														int[io_idx] = arg_2
													end
												end
											elseif type(arg_2)=="string" then
												if io_type:sub(2,2)=="t" then
													if arg_2=="abs" or arg_2=="enc" then
														  data_type[io_idx] = arg_2
													end
												end
											end
										end
										if arg_3~=nil then
											if type(arg_3)=="number" then
												if io_type:sub(2,2)=="v" then
													if arg_3 >= 0 and arg_2 <= midi_max_val then
														max[io_idx] = (arg_3 * midi_rat) * def_dlt[io_idx]
                            dlt[io_idx] = max[io_idx] - min[io_idx]
                            rat[io_idx] = (1 / dlt[io_idx])
													end
												elseif io_type:sub(2,2)=="i" then
													if arg_3 >= 1 and arg_3 <= midi_max_val+1 then
														step[io_idx] = arg_3
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

--[[  midi editing function, applies to all midi related variables
      SYNTAX:

          _m(16,1,128,1,0,127)

      ARGUMENTS:
          ch_n    :  1 to 16              --  midi channel
          bind_b  :  0 (false), 1 (true)  --  bind to a virtual layer
          ly_n    :  1 to n               --  virtual layer address
          k_state :  0 (false), 1 (true)  --  enable or disable the master keyboard for this device

          NOTE: The following arguments are safeguarded so that if k_hi goes below k_lo or vise versa,
                the placement of these values in the surface become switched to ensure proper functioning.

          k_lo    :  0 to 127             --  define the lowest key of the keyboard split for this device
          k_hi    :  0 to 127             --  define the highest key of the keyboard split for this device
  ]]

function _m(ch_n,bind_b,ly_n,k_state,k_lo,k_hi)
	if ch_n~=nil and ch_n > 0 and ch_n < 17 then
		midi_channel = string.sub(hex(ch_n-1), -1)
	end
	if bind_b~=nil then
		if bind_b==1 then
			bind_to_ly = true
      ly_selected = 1
			-- if there is no address, look for an assignment
			if ly_address==nil then
				if ly_n~=nil then
					if ly_n >= 1 and ly_n <= max_layer_count then
						ly_address = ly_n
					else
						-- assign layer 1 if none provided
						ly_address = 1
					end
				end
			end
		elseif bind_b==0 then
			bind_to_ly = false
		end
	end
	if ly_n~=nil then
		if ly_n >= 1 and ly_n <= max_layer_count then
			ly_address = ly_n
		end
	end
	if k_state~=nil then
		if k_state==1 then
			kb_enabled = true
		elseif k_state==0 then
			kb_enabled = false
		end
	end
	if k_lo~=nil then
		if k_lo >= 0 and k_lo <= midi_max_val then
			min[kb_idx] = k_lo
		end
	end
	if k_hi~=nil then
		if k_hi >= 0 and k_hi <= midi_max_val then
			max[kb_idx] = k_hi
		end
	end
end

--[[  keyboard editing function, applies to all keyboard related variables
      SYNTAX:

           _k(1,0,127)

      ARGUMENTS:
          k_state :  0 (false), 1 (true)  --  enable or disable the master keyboard for this device

          NOTE: The following arguments are safeguarded so that if k_hi goes below k_lo or vise versa,
                the placement of these values in the surface become switched to ensure proper functioning.

          k_lo    :  0 to 127             --  lowest key for the keyboard split of this device
          k_hi    :  0 to 127             --  highest key for the keyboard split of this device
  ]]

function _k(k_state,k_lo,k_hi)
	if k_state~=nil then
		if k_state==1 then
			kb_enabled = true
		elseif k_state==0 then
			kb_enabled = false
		end
	end
	if k_lo~=nil then
		if k_lo >= 0 and k_lo <= midi_max_val then
			min[kb_idx] = k_lo
		end
	end
	if k_hi~=nil then
		if k_hi >= 0 and k_hi <= midi_max_val then
			max[kb_idx] = k_hi
		end
	end
end

function terminal()
	-- this is where the parsing happens
	-- no data checking, but pre-formatting
	local rgitv = remote.get_item_text_value
	last_terminal = this_terminal
	this_terminal = rgitv(terminal_idx)
	if this_terminal~=last_terminal then
		local find_func = function(t)
			local func = {"_r", "_g", "_p", "_m", "_k"}
			local f_str = nil
			local f_bool = false
			for f=1,#func do
				local a,b = t:find(func[f])
				if a==1 and b==2 then
					f_str = t:sub(a,b)
					return f_str
					--break
				end
			end
			return nil
		end
		local find_pars = function(t)
			local p1 = t:find("%(")
			local p2 = t:find(")")
			if p1==3 and p2==t:len() then
				return p1+1,p2-1
			else
				return nil,nil
			end
		end
		local f_type = find_func(this_terminal)
		if f_type~=nil then
			local seek_a,seek_b = find_pars(this_terminal)
			if seek_a~=nil and seek_b~=nil then
				local arg_str = this_terminal:sub(seek_a,seek_b)
				if arg_str:len() >= 1 then
					-- dynamically run the command
					assert(loadstring(f_type.."("..arg_str..")"))()
				end
			end
		end
	end
end

--[[  End: Terminal   ]]

--[[ BEGIN: Interpolation Engine  ]]

-- ported from Javascript
function create_shapes()
  local log = math.log
  local sin = math.sin
  local pi = math.pi
  local s_array = {}
  for s=0,7 do
    local s_data = {}
    for d=0,127 do
      if s==0 then
        --  instant/snap (square wave)
        s_data[#s_data+1] = 1
      elseif s==1 then
        --  reciprocal (fast attack)
        s_data[#s_data+1] = (1-(1/((35*(d/127))+1)))*(1/(1-(1/36)))
      elseif s==2 then
        --  logarithmic (ease-in)
        s_data[#s_data+1] = log(10*((d/127)+0.1))*(1/log(11))
      elseif s==3 then
        --  sine (ease-in-out)
        s_data[#s_data+1] = (sin(3*pi/2+((d/127)*pi))*0.5)+0.5
      elseif s==4 then
        --  tangent (hesitate)
        s_data[#s_data+1] = (d/127)+((d/127)-((sin(3*pi/2+((d/127)*pi))*0.5)+0.5))
      elseif s==5 then
        --  reverse logarithmic (ease-out)
        s_data[#s_data+1] = 1-(log(10*((1-(d/127))+0.1))*(1/log(11)))
      elseif s==6 then
        --  reverse reciprocal (fast release)
        s_data[#s_data+1] = -((1/36)*(1/(1-(1/36))))+(1/((35*(1-(d/127)))+1))*(1/(1-(1/36)))
      elseif s==7 then
        --  hard delay (square wave)
        if d==127 then
          s_data[#s_data+1] = 1
        else
          s_data[#s_data+1] = 0
        end
      end
    end
    s_array[#s_array+1] = s_data
  end
  return s_array
end

-- ported from Javascript
function create_blends(sh)
  local b_array = {}
  for b=1,7 do
    local b_data = {}
    for d=1,128 do
      b_data[#b_data+1] = sh[b+1][d]-sh[b][d]
    end
    b_array[#b_array+1] = b_data
  end
  return b_array
end

--  ported from Javascript
function build_interp_table()
  local s_obj     = create_shapes()
  local b_obj     = create_blends(s_obj)
  local floor     = math.floor
  local i_data    = {}
  for my_pointer=0,127 do
    local n       = floor((7/127)*my_pointer)
    local pct     = ((7/127)*my_pointer) - n
    for p=0,127 do
      if n==7 then
        i_data[#i_data+1] = s_obj[n+1][p+1]
      else
        i_data[#i_data+1] = (s_obj[n+1][p+1]+(b_obj[n+1][p+1]*pct))
      end
    end
  end
  return i_data
end

--[[ END: Interpolation Engine    ]]

--[[  CONSTRUCTOR   ]]
--  written:  10/03/16

function architect(i_num, o_num, d_in, d_out, m_ch, m_ly)
  local floor     = math.floor
  local io_n      = i_num * o_num
	i_count					= i_num
	o_count					= o_num

  --  Assign core globals for logic structure
  midi_channel    = m_ch~=nil and string.sub(hex(m_ch-1), -1) or "?"
  ly_address      = m_ly~=nil and m_ly or nil
  bind_to_ly      = ly_address~=nil and true or false
  ly_selected     = bind_to_ly==true and 1 or nil

	--[[	BUILD DEVICE						]]
  --  Build data structures for virtual outs [1, io_n]
  for vi=1,io_n do
    min[#min+1]   = d_out[1]
		def_min[#def_min+1] = d_out[1]
    max[#max+1]   = d_out[2]
		def_max[#def_max+1] = d_out[2]
    dlt[#dlt+1]   = d_out[2] - d_out[1]
		def_dlt[#def_dlt+1] = d_out[2] - d_out[1]
    mid[#mid+1]   = floor((d_out[2] - d_out[1]) * 0.5)
    int[#int+1]   = 1
    step[#step+1] = 127
    rat[#rat+1]   = 1 / (d_out[2] - d_out[1])   -- VST Edit: swapping with VI's
    noedit[#noedit+1]   = false
		this[#this+1] = nil
		last[#last+1] = nil
  end

  --  Insert blanks for warning message/null items (preserves correct addressing)
  for xx=1,3 do
    min[#min+1]   = 0
		def_min[#def_min+1] = 0
    max[#max+1]   = 0
		def_max[#def_max+1] = 0
    dlt[#dlt+1]   = 0
		def_dlt[#def_dlt+1] = 0
    mid[#mid+1]   = 0
    int[#int+1]   = 1
    step[#step+1] = 128   --  stop creating these here, only needed for VO's.
    rat[#rat+1]   = 0
    noedit[#noedit+1]   = false
		this[#this+1] = nil
		last[#last+1] = nil
  end

  --  Build data structures for data sources [io_n+4, io_n+i_num]
  for i=1,i_num do
    min[#min+1]   = d_in[i].min
		def_min[#def_min+1] = d_in[i].min
    max[#max+1]   = d_in[i].max
		def_max[#def_max+1] = d_in[i].max
    dlt[#dlt+1]   = d_in[i].max - d_in[i].min
		def_dlt[#def_dlt+1] = d_in[i].max - d_in[i].min
    mid[#mid+1]   = d_in[i].min + floor((d_in[i].max - d_in[i].min) * 0.5)
    int[#int+1]   = 1
    step[#step+1] = 127
    rat[#rat+1]   = 0                                 -- VST EDIT: swapping with VI's
    noedit[#noedit+1]   = false
		this[#this+1] = nil
		last[#last+1] = nil
  end

  --  Build reverse-lookup table to data sources from VI's
  --  Build output indexes relative to data source
  for i=1,i_num do
    for o=1,o_num do
      idx[#idx+1] = io_n+3+i
      odx[#odx+1] = o
    end
  end

	--[[  Define Interpolation Data   ]]
	interp_table = build_interp_table()

  --  Tell the script the entity loaded properly
  entity_loaded   = true
end

-- user input, receives event, last known good (toggle button support)
function user_input(e)
  local rmm=remote.match_midi                               --  local references to globals
  for m=1,8 do                                              --  look through the possible user input events
    local ui_event=rmm(ui[m], e)
    if ui_event~=nil then                                   --  if we find a match
      if m==6 and ui_event.x==midi_max_val then             --  if this is navigate layers (down)
        if ly_selected~=nil then
					ly_selected = ly_selected-1                 --  decrement selected layer
				end
        --[[  NOTE: m==6 is an exception to all other user input variations.
                    no latches or states are toggled. ]]
			elseif m==6 and ui_event.x==1 then                     --  if this is navigate layers (up)
				if ly_selected~=nil then
          ly_selected = ly_selected+1                 --  increment selected layer
				end
      else
        if ui[m+8]==0 then                                  --  if the latch is open
          ui[m+16]  = not ui[m+16]                          --  toggle the state
          ui[m+8]   = 1                                     --  close the latch to prevent strobing
        end
      end
		else
      if ui[m+8]==1 then                                  --  if the latch is closed
        ui[m+8]   	= 0                                     --  open the latch
      end
    end
  end
end

--  user input, receives event, expects midi gate (except navigate layers)
--[=[function user_input(e)
  local rmm=remote.match_midi                               --  local references to globals
  for m=1,8 do                                              --  look through the possible user input events
    local ui_event=rmm(ui[m], e)
    if ui_event~=nil then                                   --  if we find a match
      if ly_selected~=nil then                           --  if we are bound to a layer
        if m==6 then                                        --  if we have detected the layer navigator
          if ui_event.x > 0 then                            --  if the data contains "1" (counter-clockwise turn)
            ly_selected = ly_selected-1               --  decrement selected layer
          elseif ui_event.x < 1 then                        --  if the data contains "0" (clockwise turn)
            ly_selected = ly_selected+1               --  increment selected layer
          end
          --[[  NOTE: m==6 (navigate layers) is an exception to all other user input variations.
                      No latches or states are toggled.     ]]
        end
      end
      if m~=6 then                                          --  if this is anything other than navigate layers...
        if ui_event.x > 0 then                              --  if the data contains "1" or higher
          if ui[m+8]==0 then                                --  if the latch is open
            ui[m+16]  = true                                --  toggle this state to "on"
            ui[m+8]   = 1                                   --  close the latch
          end
        else ui_event.x==0 then                             --  if the data contains "0"
          if ui[m+8]==1 then                                --  if the latch is closed
            ui[m+16]  = false                               --  toggle this state to "off"
            ui[m+8]   = 0                                   --  open the latch
          end
        end
      end
    end
  end
end]=]

--  check to see if we are editing
function editing()
  if ui[20]==true or ui[21]==true or ui[23]==true or ui[24]==true then  --  if any of the editing states are toggled "on"
    return true                                 --  say "yes"
  else                                          --  otherwise...
    return false                                --  say "no"
  end
end

--	ignore kb vars, these are data sources that can only update via midi
function ignore(num)
	if kb_enabled and kb_idx~=nil then
		if num==kb_idx or num==pressure_idx or num==expression_idx or num==damper_idx or num==breath_idx then
			return true
		else
			return false
		end
	end
end

--  allow editing and data flow on certain conditions
function surface_active()
  if bind_to_ly==true then
    if ly_selected~=nil and ly_address~=nil then
      if ly_selected~=ly_address then
        return false
      elseif ly_selected==ly_address then
        return true
      end
    end
  else
    return true
  end
end

--[[	Universal Data Write 		]]

-- data write algorithm, receives event
function write_to_rack(e)
  local rhi=remote.handle_input                               --  local references to globals
  for i,v in ipairs(g_batch) do                               --  look through the contents of g_batch
		local v_num = tonumber(v)																	--	convert k to a number so rhi can use it
		local n = g_batch[v][1]                                   --  retrieve the first LIFO order interpolation value stored in g_batch for virtual out "k"
    local write_msg = {                                       --  create a data write message to be sent to the rack
      item        = v_num,                                    --  apply key "k" as item index
      value       = g_batch[v][n],                            --  apply retrieved interpolation value as the value for virtual out "k"
      time_stamp  = e.time_stamp                              --  apply event.time_stamp as passed via param "e"
    }
    rhi(write_msg)                                            --  write message to the rack
		if g_batch[v][1] > 2 then
			g_batch[v][1] = g_batch[v][1] - 1
		end
  end
end

--[[	Begin Data network		]]

-- data network write function
function process_network(event)
	local rmm = remote.match_midi
	local rhi = remote.handle_input
  local format = string.format

  user_input(event)                                           --  process user input first, all processes internal
	if ui[17]==false and surface_active() then                           --  if the system has not panicked and the layer is active
		--	if we are editing
		if editing() then
			--	if the keyboard is enabled
			if kb_enabled and kb_idx~=nil then
				local ne_fmt = midi_channel~="?" and format("%x",(midi_channel-1)) or midi_channel
				local ne_event = rmm("<100x>"..ne_fmt.." yy zz", event)
				--	if a note has been detected
				if ne_event~=nil then
					--	edit lo key
					if ui[23] then
						--	only apply edits when keys are pressed
						if ne_event.x > 0 then
							min[kb_idx] = ne_event.y
							-- auto-correct keyboard splits
							if min[kb_idx] > max[kb_idx] then
								local temp_hi = max[kb_idx]
								min[kb_idx] = max[kb_idx]
								max[kb_idx] = temp_hi
							end
							dlt[kb_idx] = max[kb_idx] - min[kb_idx]
							rat[kb_idx] = 1 / dlt[kb_idx]
						end
						--	play the note to allow for user confirmation by ear
						local lo_msg = {
							item			= kb_idx,
							value 		= ne_event.x,
							note 			= ne_event.y,
							velocity	= ne_event.z,
							time_stamp= event.time_stamp
						}
						rhi(lo_msg)
					end
					--	edit hi key
					if ui[24] then
						if ne_event.x > 0 then
							max[kb_idx] = ne_event.y
							if max[kb_idx] < min[kb_idx] then
								local temp_lo = min[kb_idx]
								max[kb_idx] = min[kb_idx]
								min[kb_idx] = temp_lo
							end
							dlt[kb_idx] = max[kb_idx] - min[kb_idx]
							rat[kb_idx] = 1 / dlt[kb_idx]
						end
						local hi_msg = {
							item			= kb_idx,
							value 		= ne_event.x,
							note 			= ne_event.y,
							velocity	= ne_event.z,
							time_stamp= event.time_stamp
						}
						rhi(hi_msg)
					end
				end
			end
		else                                    --  only write to the rack if we are not editing
      -- handle note input before any data
      if kb_enabled and kb_idx~=nil then
				local ch_fmt = midi_channel~="?" and format("%x",midi_channel) or midi_channel
        local nt_event = rmm("<100x>"..ch_fmt.." yy zz", event)
        if nt_event~=nil then
					if nt_event.y >= min[kb_idx] and nt_event.y <= max[kb_idx] then
	          local nt_msg = {
	            item      = kb_idx,
	            value     = nt_event.x,
	            note      = nt_event.y,
	            velocity  = nt_event.z,
	            time_stamp= event.time_stamp
	          }

	          rhi(nt_msg)
						batch_midi(nt_event.y, kb_idx)
					end
        end
				local pb_event = rmm("e"..ch_fmt.." xx yy", event)
				if pb_event~=nil then
					local pb_msg = {
						item			= pitch_idx,
						value			= pb_event.y*128+pb_event.x,
						time_stamp= event.time_stamp
					}
					rhi(pb_msg)
					--batch_midi(pb_msg.value, pitch_idx)    --  this is causing a problem with the warp engine
				end
--[[
				local md_event = rmm("b"..ch_fmt.." 01 xx", event)
				if md_event~=nil then
					local md_msg = {
						item 			= mod_idx,
						value			= md_event.x,
						time_stamp= event.time_stamp
					}
					rhi(md_msg)
				end
				local ch_event = rmm("d"..ch_fmt.." xx", event)
				if ch_event~=nil then
					local ch_msg = {
						item			= pressure_idx,
						value			= ch_event.x,
						time_stamp= event.time_stamp
					}
					rhi(ch_msg)
					batch_midi(ch_event.x, pressure_idx)
				end
				local ex_event = rmm("b"..ch_fmt.." 0b xx", event)
				if ex_event~=nil then
					local ex_msg = {
						item			= expression_idx,
						value			= ex_event.x,
						time_stamp= event.time_stamp
					}
					rhi(ex_msg)
					batch_midi(ex_event.x, expression_idx)
				end
				local dp_event = rmm("b"..ch_fmt.." 40 xx", event)
				if dp_event~=nil then
					local dp_msg = {
						item			= damper_idx,
						value			= dp_event.x,
						time_stamp= event.time_stamp
					}
					rhi(dp_msg)
					batch_midi(dp_event.x, damper_idx)
				end
				local br_event = rmm("b"..ch_fmt.." 02 xx", event)
				if br_event~=nil then
					local br_msg = {
						item			= breath_idx,
						value			= br_event.x,
						time_stamp= event.time_stamp
					}
					rhi(br_msg)
					batch_midi(br_event.x, breath_idx)
				end]]
      end
      if #g_batch>0 then           														--  only proceed if there is anything to process
        write_to_rack(event)                                  --  write data to the rack
        return true                                           --  tell Reason the events have been used
      end
  	end
  end
end

--  data read algorithm, receives table "changed_items"
function read_network(t)
  local riie    = remote.is_item_enabled
  local rgiv    = remote.get_item_value
  local rgin    = remote.get_item_name
  local floor   = math.floor
  local o_n     = o_count
  local io_n    = i_count * o_count

  for i=1,#t do
    local n=t[i]
    if n==terminal_idx then
			terminal()
		else
      --  if we are editing
      if editing() then
				this[n] = rgiv(n)
				if this[n]~=last[n] then
          if noedit[n]==false then
  					if ui[23]==true then
  						min[n] = rgiv(n)
  						dlt[n] = max[n] - min[n]
  						mid[n] = min[n] + floor(min[n] + (dlt[n] * 0.5))
  					end
  					if ui[24]==true then
  						max[n] = rgiv(n)
  						dlt[n] = max[n] - min[n]
  						mid[n] = min[n] + floor(min[n] + (dlt[n] * 0.5))
  					end
          end
	        if n<=io_n then                              -- VST Edit: ratios and interp edits for VI's only
            if noedit[n]==false then
	             rat[n] = 1 / dlt[n]
            end
	          if ui[20]==true then    --  curve edit
							local c_val = floor((rgiv(n)-min[n])*rat[n])
	            int[n]  = floor(c_val * midi_max_val)+1
	          end
	          if ui[21]==true then    --  step edit
							local s_val = floor((rgiv(n)-min[n])*rat[n])
	            step[n] = floor(s_val * midi_max_val)+1
	          end
	        end
          last[n] = this[n]
				end
      --  if we are not editing
      else
        if n<=io_n then                               -- VST Edit: generate batches from VI's
					batch_net(n)
				end
      end
    end
  end
end

--	read the value of a parameter and generate an interpolation batch
function batch_net(n)
	local floor = math.floor
	local riie = remote.is_item_enabled
	local rgiv = remote.get_item_value
	local rgin = remote.get_item_name
	local ignore = ignore
	local o_n = o_count
	local io_n = i_count * o_count

	if riie(n) then			--  only proceed if surface is locked
		if not ignore(n) then		--	only proceed if this is not an item that requires midi input to function
			local float = nil
			if ui[18]==true then                                    --  if we are in bipolar mode
				float = (rgiv(n) - mid[n]) * (rat[n] * 0.5)           --  precalculate the float value in the range [-1,	1]
				float = float >= -1 and float or -1                   --  conditionally constrain the floor of the float value to -1
				float = float <= 1 and float or 1                     --  conditionally constrain the ceiling of the float value to 1
			else                                                  --  if we are in unipolar mode
				float = (rgiv(n) - min[n]) * rat[n]                   --  precalculate the float value in the range [0,		1]
				float = float >= 0 and float or 0                     --  conditionally constrain the floor of the float value to 0
				float = float <= 1 and float or 1                     --  conditionally constrain the ceiling of the float value to 1
			end

      local o = io_n+3+n

			if riie(o) then
				local o_str = tostring(o)
				if g_batch[o_str] == nil then table.insert(g_batch, o_str) end
				g_batch[o_str] = {2}
				local dy1   = rgiv(o)                       --  extract the current position of virtual out "o"
				local dy2   = nil

				if ui[18]==true then
					dy2 = floor(mid[o] + (float * (dlt[o] * 0.5)))
				else
					dy2 = floor(min[o] + (float * dlt[o]))
				end

				local dy    = dy2 - dy1                           --  store the difference between the two positions
				local px    = int[o] * (midi_max_val+1)           --  create a pointer to the interpolation curve variation (i think this is correct)

				for cr=midi_max_val+1, step[o], -step[o] do       --  retrieve data entries stored within curve "px"
					g_batch[o_str][#g_batch[o_str]+1]  = floor(dy1 + (interp_table[px+cr] * dy))   --  store the curve data in reverse order
				end
				g_batch[o_str][1] = #g_batch[o_str]
			end
		end
	end
end

--	data network set state
function set_network(changed_items)
  if ui[17]==false and surface_active() then										--  if the system has not panicked
    if type(changed_items)=="table" then
			if #changed_items>0 then						--  only proceed if there is something to process
      	read_network(changed_items)          --  read from the changed items, for loop internal
			end
    end
  end
end

--[[	End Data network		]]

--	read a midi value and generate an interpolation batch
function batch_midi(h, n)
	local floor = math.floor
	local riie = remote.is_item_enabled
	local rgiv = remote.get_item_value
	local o_n = o_count
	local io_n = i_count * o_count

	local float = nil
	if ui[18]==true then                                    --  if we are in bipolar mode
		float = (h - mid[n]) * (rat[n] * 0.5)           --  precalculate the float value in the range [-1,	1]
		float = float >= -1 and float or -1                   --  conditionally constrain the floor of the float value to -1
		float = float <= 1 and float or 1                     --  conditionally constrain the ceiling of the float value to 1
	else                                                  --  if we are in unipolar mode
		float = (h - min[n]) * rat[n]                   --  precalculate the float value in the range [0,		1]
		float = float >= 0 and float or 0                     --  conditionally constrain the floor of the float value to 0
		float = float <= 1 and float or 1                     --  conditionally constrain the ceiling of the float value to 1
	end

	local o=n--io_n+3+n

	local o_str = tostring(o)
	if g_batch[o_str] == nil then table.insert(g_batch, o_str) end
	g_batch[o_str] = {2}
	local dy1   = rgiv(o)                             --  extract the current position of virtual out "o"
	local dy2   = nil
	if ui[18]==true then
		dy2 = floor(mid[o] + (float * (dlt[o] * 0.5)))
	else
		dy2 = floor(min[o] + (float * dlt[o]))
	end
	local dy    = dy2 - dy1                           --  store the difference between the two positions
	local px    = int[o] * (midi_max_val+1)           --  create a pointer to the interpolation curve variation (i think this is correct)
	for cr=midi_max_val+1, step[o], -step[o] do       --  retrieve data entries stored within curve "px"
		g_batch[o_str][#g_batch[o_str]+1]  = floor(dy1 + (interp_table[px+cr] * dy))   --  store the curve data in reverse order
	end
	g_batch[o_str][1] = #g_batch[o_str]
end

--	--	END CORE LOGIC 	--	--
_G["define_massive_input_mode"] = function()
	local rdi = remote.define_items

	local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
	local outputs = {}

  -- master keyboard items --
	names[#names+1] = "Keyboard"
	names[#names+1] = "Pitch Bend"
	names[#names+1] = "Mod Wheel"
	names[#names+1] = "Channel Pressure"
	names[#names+1] = "Expression"
	names[#names+1] = "Damper Pedal"
	names[#names+1] = "Breath"
  -- begin VST items --
	names[#names+1] = "Proxy Pitch Bend"
	names[#names+1] = "Proxy Mod Wheel"
  --[=[
	names[#names+1] = "Proxy Enabled"
  names[#names+1] = "Proxy Note On Indicator"
  names[#names+1] = "Proxy CV Input Indicator"
  names[#names+1] = "Proxy Parameter Automation Indicator"
  names[#names+1] = "Proxy Input Audio Meter"
  names[#names+1] = "Proxy Output Audio Meter"
  names[#names+1] = "Proxy Power Button"
  ]=]
  for mc=1,8 do
    names[#names+1] = "MACRO "..mc
  end
  for ft=1,3 do
    names[#names+1] = "OSC"..ft.."-PITCH"
    names[#names+1] = "OSC"..ft.."-POSITION"
    names[#names+1] = "OSC"..ft.."-PARAM2"
    names[#names+1] = "OSC"..ft.."-AMP"
    names[#names+1] = "OSC"..ft.."-FLT.ROUTING"
  end
	names[#names+1] = "NOISE-COLOR"
	names[#names+1] = "NOISE-AMP"
	names[#names+1] = "NSE-F.RT"
	names[#names+1] = "F.BACK-AMP"
	names[#names+1] = "FB-FLT.ROUTING"
	names[#names+1] = "MOD.OSC-PITCH"
	names[#names+1] = "M.OSC-RM"
	names[#names+1] = "MOD.OSC-PHASE"
	names[#names+1] = "MOD.OSC-POSITION"
	names[#names+1] = "MOD.OSC-FLTR.FM"
  for ft2=1,2 do
    names[#names+1] = "FILTER"..ft2.."-CUT"
    names[#names+1] = "FILTER"..ft2.."-BW"
    names[#names+1] = "FILTER"..ft2.."-RES"
  end
  names[#names+1] = "SERIELL-PARALLEL"
  for ins=1,2 do
    names[#names+1] = "INSERT"..ins.."-DW/PRM1"
    names[#names+1] = "INSERT"..ins.."-PRM2"
  end
  for mfx=1,2 do
    names[#names+1] = "MASTER FX"..mfx.."-DW"
    for mfx_p=2,4 do
      names[#names+1] = "MASTER FX"..mfx.."-PRM."..mfx_p
    end
  end
  for ft3=1,2 do
    names[#names+1] = "FILTER"..ft3.."-OUT GAIN"
  end
  names[#names+1] = "FLT.1/2-C.FADE"
  names[#names+1] = "BYPASS-GAIN"
  names[#names+1] = "PAN (Fltr-Path)"
  names[#names+1] = "MASTER-VOLUME"
  for md1=5,8 do
    names[#names+1] = "MOD"..md1.."-RTE"
  end
  for md2=5,8 do
    names[#names+1] = "MOD"..md2.."-AMP"
  end
  for md3=5,8 do
    names[#names+1] = "MOD"..md3.."-CF/G"
  end
  for md4=5,8 do
    names[#names+1] = "MOD"..md4.."-I.LV"
  end
  for md5=1,4 do
    names[#names+1] = "MOD"..md5..(md5+4).."-SNC"
  end
  for md6=5,8 do
    names[#names+1] = "MOD"..md6.."-RST"
  end
  for ev1=1,4 do
    names[#names+1] = "ENV"..ev1.."-VEL"
  end
  for ev2=1,4 do
    names[#names+1] = "ENV"..ev2.."-KTR"
  end
  for ev3=1,4 do
    names[#names+1] = "ENV"..ev3.."-DLY"
  end
  for ev4=1,4 do
    names[#names+1] = "ENV"..ev4.."ATT.T"
  end
  for ev5=1,4 do
    names[#names+1] = "ENV"..ev5.."ATT.L"
  end
  for ev6=1,4 do
    names[#names+1] = "ENV"..ev6.."DEC.T"
  end
  for ev7=1,4 do
    names[#names+1] = "ENV"..ev7.."DEC.L"
  end
  for ev8=1,4 do
    names[#names+1] = "ENV"..ev8.."SST.T"
  end
  for ev9=1,4 do
    names[#names+1] = "ENV"..ev9.."SST.L"
  end
  for ev10=1,4 do
    names[#names+1] = "ENV"..ev10.."MORPH"
  end
  for ev11=1,4 do
    names[#names+1] = "ENV"..ev11.."REL.T"
  end
  names[#names+1] = "GLIDE-TIME"
  names[#names+1] = "VIBRATO-RATE"
  names[#names+1] = "VIBRATO-DEPTH"
  names[#names+1] = "UNI PITCH-C.FADE"
  names[#names+1] = "UNI WTPOS-C.FADE"
  names[#names+1] = "UNI PAN-C.FADE"
  names[#names+1] = "EQ-LoShelf.BOOST"
  names[#names+1] = "EQ-Peak.BOOST"
  names[#names+1] = "EQ-Peak.FREQ"
  names[#names+1] = "EQ-HiShelf.Boost"
  names[#names+1] = "Env.Hold Reset"
  for md7=5,8 do
    names[#names+1] = "MOD"..md7.."-NUM"
  end
  for md8=5,8 do
    names[#names+1] = "MOD"..md8.."-DEN"
  end
  for md9=5,8 do
    names[#names+1] = "MOD"..md9.."-SCP"
  end
  names[#names+1] = "Proxy Open Plugin Window"

	in_count = #names
	_G["g_names"] = names

	data[#data+1] = {min=0, max=127}
	data[#data+1] = {min=0, max=16383}
	data[#data+1] = {min=0, max=127}
	data[#data+1] = {min=0, max=127}
	data[#data+1] = {min=0, max=127}
	data[#data+1] = {min=0, max=127}
	data[#data+1] = {min=0, max=127}
	data[#data+1] = {min=0, max=16383}
	data[#data+1] = {min=0, max=127}
  --[=[
	data[#data+1] = {min=0, max=2}
	data[#data+1] = {min=0, max=1}
	data[#data+1] = {min=0, max=1}
	data[#data+1] = {min=0, max=1}
	data[#data+1] = {min=0, max=20}
	data[#data+1] = {min=0, max=20}
	data[#data+1] = {min=0, max=1}
  ]=]
  for pop1=1,149 do
	  data[#data+1] = {min=0, max=4194304}
  end
	data[#data+1] = {min=0, max=1}

  out_count = 1

	-- build the architecture to fit this device
  architect(in_count, out_count, data, out_data)

  -- create the virtual inputs
  for i=1,in_count do
    items[#items+1] = {name="Send To - "..names[i], input="value", min=out_data[1], max=out_data[2], output="value"}
  end

  -- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

	-- create the data sources
  for i=1,in_count do
		if names[i]=="Keyboard" then
			items[#items+1] 	= {name=names[i], input="keyboard"}
			kb_idx						= #items
			kb_enabled 				= true
		else

    	items[#items+1] 	= {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}

			if names[i]=="Pitch Bend" then
				pitch_idx 			= #items
			elseif names[i]=="Mod Wheel" then
				mod_idx 				= #items
			elseif names[i]=="Channel Pressure" then
				pressure_idx 		= #items
			elseif names[i]=="Expression" then
				expression_idx	= #items
			elseif names[i]=="Damper Pedal" then
				damper_idx 			= #items
			elseif names[i]=="Breath" then
				breath_idx 			= #items
			end
		end
  end

	-- define the data terminal
	items[#items+1] 			= {name="Data Terminal", input="noinput", output="text"}
	terminal_idx 					= #items
	-- define the internals of the terminal
	build_terminal()
	rdi(items)
end

-- constructor
-- written:  06/04/2016
function remote_init(manufacturer, model)
	assert(manufacturer=="Raveshaper")
	local model_fmt=string.lower(model)
	local model_prs={}
	local model_fnc="define"
  device_type = model_fmt                                                  -- store a copy of the raw device type

	for word in model_fmt:gmatch("%w+") do table.insert(model_prs, word) end -- define a dynamic function based on model name
  for w=1,table.getn(model_prs) do model_fnc = model_fnc .. "_" .. model_prs[w] end
  if (type(_G[model_fnc])=="function") then _G[model_fnc]() end            -- call the dynamic function
end

-- remote data write
-- written: 04/05/2016
function remote_process_midi(event)
	if entity_loaded then
		if reason_document then
			process_document(event)
	  elseif midi_controller then
	  	process_controller(event)
		else
	  	process_network(event)
		end
	end
end

-- remote data read
-- written: 06/05/2016
function remote_set_state(changed_items)
	if entity_loaded then
		if reason_document then
			set_document(changed_items)
	  elseif midi_controller then
	  	set_controller(changed_items)
		else
	  	set_network(changed_items)
		end
	end
end

lua = {
  mod = function (a, b)
    local out = a - math.floor(a/b) * b
    return out
  end,
  dectobin = function (n)
		if (n==64) then
			return "000000"
		else
	    local out = {}
			while n>0 do
				local r=math.fmod(n,2)
				out[#out+1]=r
				n=(n-r)/2
			end
			local bits = #out
			if (bits<6) then
				for i=1,(6-bits) do
					out[#out+1] = 0
				end
			end
			local out_str = ""
			for j=#out,1,-1 do
				out_str = out_str .. out[j]
			end
			return out_str
		end
  end,
	bintodec = function (s)
		local out = 0
		for i=1,s:len() do
			local n = tonumber(s:sub(i,i)) * (2^(8-i))
			out = out + n
		end
		return out
	end
}

--CODES = [[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=]]
--[[
function decode(s)
  if (lua.mod(s:len(), 4)~=0) then error("Invalid or Corrupted Base64 Input") end
  local decoded = ""
  local c={}
  for i=1, (s:len()-3), 4 do
    c[1] = CODES:find(s:sub(i, i))
    c[2] = CODES:find(s:sub(i+1, i+1))
    c[3] = CODES:find(s:sub(i+2, i+2))
    c[4] = CODES:find(s:sub(i+3, i+3))
    local BINARY_WORD = lua.dectobin(c[1])..lua.dectobin(c[2])..lua.dectobin(c[3])..lua.dectobin(c[4])
		local BYTE_1 = BINARY_WORD:sub(1, 8)
		local BYTE_2 = BINARY_WORD:sub(9, 16)
		local BYTE_3 = BINARY_WORD:sub(17, 24)
		decoded = decoded .. string.char(lua.bintodec(BYTE_1))
		decoded = decoded .. string.char(lua.bintodec(BYTE_2))
		decoded = decoded .. string.char(lua.bintodec(BYTE_3))
  end
  return decoded
end

function encode(s)
	if (s~=nil) then
		local b = nil
		local out = ""
		for i=1, s:len(), 3 do
			b = bit.rshift(bit.band(s:byte(i), 0xFC), 2)
			out = out .. CODES:sub(b,b)
			b = bit.lshift(bit.band(s:byte(i), 0x03), 4)
			if (i + 1 <= s:len()) then
				b = bit.bor(b, bit.rshift(bit.band(s:byte(i+1), 0xF0), 4))
				out = out .. CODES:sub(b,b)
				b = bit.lshift(bit.band(s:byte(i+1), 0x0F), 2)
				if (i + 2 <= s:len()) then
					b = bit.bor(b, bit.rshift(bit.band(s:byte(i+2), 0xC0), 6))
					out = out .. CODES:sub(b,b)
					b = bit.band(s:byte(i+2), 0x3F)
					out = out .. CODES:sub(b,b)
				else
					out = out .. CODES:sub(b,b)
					out = out .. "="
				end
			else
				out = out .. CODES:sub(b,b)
				out = out .. "=="
			end
		end
		return out
	end
end
]]

--assert(loadstring(decode(src_str)))()
