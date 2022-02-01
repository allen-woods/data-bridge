--[[  DataBridge  v5.0.0
      Author:     Allen Woods

      Desc:       DataBridge is a collection of control surfaces whose Architecture has been
                  designed to operate as a unified, scalable, modular system that enables
                  real time dynamic modulations, advanced MIDI mappings, and unprecedented
                  live performance capabilities within Reason 7 or higher.

                  Thank you for using DataBridge, and enjoy!
  ]]

--[[  BEGIN: Virtual Output Counts

      Entries in this section define the number of virtual outputs for all control types
      (button, knob, slider) in the context of the target device type.

      The global output entry directly below defines the default number of virtual outputs
      across all loaded control surfaces in the context of device types whose virtual output
      counts have been intentionally left undefined (nil).

      IMPORTANT:
        * All values must be positive integers greater than or equal to 1, or nil.
        * Virtual output counts in the context of a device type take precedence.
        * Virtual output counts in the context of a device type are global for all instances.
        * If all virtual output counts are nil in size, the system defaults to a network
          with 1 virtual output for each control type, globally.
        * Very large numbers will cause a significant drop in performance.
]]

_G["Global_outputs"] = 2 -- data network (global)

_G["Midi_controller_outputs"] = nil -- midi controller (CC# messages)

_G["Document_transport_outputs"] = nil -- reason UI application items
_G["Regroove_mixer_outputs"] = nil
_G["Master_section_outputs"] = nil

_G["Kong_outputs"] = nil -- instruments
_G["Redrum_outputs"] = nil
_G["Thor_outputs"] = nil
_G["Subtractor_outputs"] = nil
_G["Malstrom_outputs"] = nil
_G["Id8_outputs"] = nil
_G["Dr_rex_outputs"] = nil
_G["Nn-xt_outputs"] = nil
_G["Nn19_outputs"] = nil
_G["External_midi_outputs"] = nil

_G["Pulveriser_outputs"] = nil -- creative fx
_G["The_echo_outputs"] = nil
_G["Alligator_outputs"] = nil
_G["Scream_4_outputs"] = nil
_G["Bv512_outputs"] = nil

_G["Rv7000_outputs"] = nil -- studio fx
_G["Neptune_outputs"] = nil
_G["Mclass_equalizer_outputs"] = nil
_G["Mclass_compressor_outputs"] = nil
_G["Mclass_maximizer_outputs"] = nil
_G["Mclass_stereo_imager_outputs"] = nil
_G["Rv-7_outputs"] = nil
_G["Ddl-1_outputs"] = nil
_G["D-11_outputs"] = nil
_G["Ecf-42_outputs"] = nil
_G["Cf-101_outputs"] = nil
_G["Ph-90_outputs"] = nil
_G["Un-16_outputs"] = nil
_G["Comp-01_outputs"] = nil
_G["Peq-2_outputs"] = nil

_G["Combinator_outputs"] = nil -- utilities
_G["Rpg-8_outputs"] = nil
_G["Matrix_outputs"] = nil
_G["Spider_audio_outputs"] = nil
_G["Spider_cv_outputs"] = nil
_G["Mixer_14-2_outputs"] = nil
_G["Line_mixer_6-2_outputs"] = nil
_G["Mix_channel_outputs"] = nil

_G["Audiomatic_outputs"] = nil -- rack extensions (propellerheads)
_G["Pulsar_outputs"] = nil
_G["Synchronous_outputs"] = nil
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

_G["Max_layer_count"] = 8
--[[  END: Virtual Layer Structure  ]]

-- global name of the current device type, for use with warp function
_G["Device_type"] = nil

-- global copy of names table; this is used by the command line editor to edit specific items
_G["G_names"] = nil


--[[  Define User Interface ]]

UI = { --  User Interface
  "b0 5e xx", --  CC 94:  Panic                       implemented
  "b0 5f xx", --  CC 95:  Relative                    implemented
  "b0 60 xx", --  CC 96:  Physics/Inertia             legacy (not currently used)
  "b0 61 xx", --  CC 97:  Curve Type                  implemented
  "b0 62 xx", --  CC 98:  Step Amount of Curve        implemented
  "b0 63 xx", --  CC 99:  Navigate Layers             implemented
  "b0 64 xx", --  CC100:  Edit Min                    implemented
  "b0 65 xx", --  CC101:  Edit Max                    implemented
  0,0,0,0, --  Latches
  0,0,0,0,
  false,false, --  States
  false,false,
  false,false,
  false,false
}

--[[  Important globals           ]]
Is_reason_document = false --  the script uses this to respond uniquely to document scope
Midi_val_to_unit_interval = 1 / 127 --  folded constant for ratios mased on midi values
Is_midi_controller = false --  the script uses this to respond to midi events
Midi_channel = "?" --  respond to all midi channels by default
Bind_to_layer = false --  boolean flag that tells this surface whether it is bound to a virtual layer
Layer_address = nil --  integer value pointing to the address of the virtual layer for this surface
Layer_is_selected = nil --  boolean flag that tells this surface what virtual layer is selected within the global system architecure
Deck_number = nil --  integer value describing the virtual deck for this surface (2 deck system on single midi port)
Deck_clock =	nil --  integer value describing the clock channel for this virtual deck
Clock_mask =	nil --  Hexadecimal string that defines the pattern the system uses to look for clock data on this virtual deck
Keyboard_is_enabled = false --  boolean flag that tells this surface whether it has master keyboard input
Has_pitch_wheel = false --  boolean flag for whether this device has a pitch wheel or not.
Warp_from = nil --  integer value that defines the project tempo at the moment the warp engine feature is enabled
Warp_from_bpm = nil --  dedicated integer value for the project tempo in bpm
Warp_from_dec = nil --  dedicated integer value for the project tempo in beats, 16ths, and ticks
Warp_is_enabled = false --  boolean flag that tells this surface the warp engine feature is enabled
Last_warp_state = false --  boolean flag that stores the previous state of Warp_is_enabled to allow for intelligent decoupling
Warp_use_24 = false --  boolean flag that tells this surface to constrain the warp engine feature to 24 semitones
Warp_24_to_unit_interval = (1 / 24) --  folded constant of the ratio for the 24 semitones
Warp_center_to_min = 8192 --  folded constant of the scalar value of the left side of the warp engine
Warp_center_to_min_to_unit_interval = (1 / Warp_center_to_min) --  folded constant of the ratio for the left side
Warp_center_to_max = 8191 --  folded constant of the scalar value of the right side of the warp engine
Warp_center_to_max_to_unit_interval = (1 / Warp_center_to_max) --  folded constant of the ratio for the right side
Surface_input_count = nil --  integer value for the number of inputs (data sources/device controls)
Surface_output_count = nil --  integer value for the number of virtual outputs per input
Default_minimum_values = {} --  table of default minimum values
Default_maximum_values = {} --  table of default maximum values
Default_delta_values = {} --  table of default delta values (max - min)
Item_is_not_editable = {} --  table of "true" boolean values for every data source that can not be edited, enabled items equal nil
User_defined_minimum_values = {} --  table of min values
User_defined_maximum_values = {} --  table of max values
User_defined_delta_values = {} --  table of delta values (max - min)
Calculated_midpoint_values = {} --  table of midpoints ((max - min) * 0.5) + min
Interpolation_curve_index = {} --  table of values ranging from 1 to 128, pointing to the specific interpolation curve variation for this virtual output
Interpolation_curve_resolution = {} --  table of values ranging from 1 to 128, indicating how many steps it takes to plot the graph of Interpolation_curve_index[]
Calculated_unit_interval_scalar_values = {} --  table of the ratios for these items (inputs and outputs)
Input_or_virtual_output_index = {} --  table of integer values that point to the index of the inputs and virtual outputs
Virtual_output_source_input_index = {} --  table of integer values that point to the index of the input these virtual outputs are branched from (reverse lookup)
Current_state = {} --  a record of the current changes
Last_state = {} --  a record of the previous changes
Rotary_encoder_minimum_ms = 25 --  BEGIN: variables used for the smooth response to endless rotary encoders
Rotary_encoder_maximum_ms = 175
Rotary_encoder_now_ms = {}
Rotary_encoder_last_ms = {}
Rotary_encoder_delta_values_ms = {}
Rotary_encoder_directional_data = {} -- END: endless rotary encoders
Global_midi_batch = {} --  the batch of data that gets written to the rack using remote.handle_input()
--  midi controller specific vars
Data_type = {} --  a table of strings indicating the type of controls mapped to the given midi message(s), such as rotary encoders, button, and knob

-- special indexes
Device_name_command_line_index = nil --  the index of the Device Name input, for command line editor functionality
Keyboard_index = nil --  the index of the master keyboard
Pitch_bend_index = nil --  the index of the Pitch Bend input, for use with the warp engine function
Pitch_bend_range_index = nil --  the index of the Pitch Bend Range input, for use with the warp engine function
Modulation_wheel_index = nil --  BEGIN: index values for the common global MIDI performance controllers (Mod, Channel Pressure, Expression, Damper, Breath)
Channel_pressure_index = nil
Expression_index = nil
Damper_index = nil
Breath_index = nil --  END: MIDI performance controllers
Midi_max_val = 127 --  the maximum midi value
Output_data_max_val = 4194048 --  the maximum value for unipolar data sent to virtual outputs
Output_data_to_unit_interval = 1 / Output_data_max_val --  the ratio of the max data value for virtual outputs
Surface_is_initialized = false --  boolean flag that tells this surface that its internal structure has been successfully initialized.

-- decimal to Hex converter
-- written:	06/15/2016
function Hex(dec)
	return string.format("%02x", dec)
end

function Round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Build_terminal()
 -- might not need latch
	_G["Current_terminal_state"] = nil
	_G["Last_terminal_state"] = nil
 -- _G["Terminal_latch"] = 0
	_G["System_resume_state"] = nil
end

--[[	TERMINAL...

      reset function For terminal, must receive "true" boolean value to execute
      SYNTAX:

           _R(1)

      ARGUMENTS:
          b = 0 (false), 1 (true)
  ]]

function _R(b)
	if b==1 then
 -- store the state of the system
		System_resume_state = UI[17]
 -- suspend user input
		UI[17] = true
		Sys_suspend = true
 -- restore defaults
		Restore_defaults()
    Bind_to_layer = false
    Layer_address = nil
    Layer_is_selected = nil
    Midi_channel = "?"
	end
end

-- default value restoration function
function Restore_defaults()
	for d=1,#Default_minimum_values do
		User_defined_minimum_values[d] = Default_minimum_values[d]
		User_defined_maximum_values[d] = Default_maximum_values[d]
    Calculated_midpoint_values[d] = User_defined_minimum_values[d] + ((User_defined_maximum_values[d] - User_defined_minimum_values[d]) * 0.5)
		User_defined_delta_values[d] = Default_delta_values[d]
    Calculated_unit_interval_scalar_values[d] = (1 / User_defined_delta_values[d])
	end
  for dt=1,#Data_type do
    Data_type[dt] = "abs"
  end
  if Is_midi_controller then
    for t=1,#Current_state do
      Current_state[t] = 64
      Last_state[t] = 64
    end
  else
    for i=1,#Interpolation_curve_index do
      Interpolation_curve_index[i] = 1
      Interpolation_curve_resolution[i] = 127
    end
  end
 -- restore the functional state of the system prior to suspension
	if System_resume_state==false then
		UI[17] = System_resume_state
	end
	Sys_suspend = false
end

--[[  global editing function, applies inputs to entire device
      SYNTAX:

           _Gl(16,1,128,enc,128,128,127,127,127,127)

      ARGUMENTS:
          ch_n   :  1 to 16 --  midi channel
          bind_b :  0 (false), 1 (true) --  bind to a virtual layer
          ly_n   :  1 to n --  virtual layer address
          d_type :  "enc" (relative input for endless rotary encoder), --  the data type of the midi input for this item
                    "abs" (fixed midi knob, 0 to 127)
          int_c  :  1 to 128 --  interpolation curve
          int_s  :  1 to 128 --  interpolation step

          NOTE: The following arguments act as ratios, where 0 = 0 and 127 = 1.
                The ratio yielded by the numeric argument is then multiplied by the
                data range of the item type (input, virtual output) and gives the final
                coarse grained data value desired.

          i_min  :  0 to 127 --  input item min val
          i_max  :  0 to 127 --  input item max val
          o_min  :  0 to 127 --  virtual output min val
          o_max  :  0 to 127 --  virtual output max val
  ]]

function _Gl(ch_n,bind_b,ly_n,d_type,int_c,int_s,i_min,i_max,o_min,o_max)
	local io_n = Surface_input_count * Surface_output_count
	if ch_n~=nil and ch_n > 0 and ch_n < 17 then
		Midi_channel = string.sub(Hex(ch_n-1), -1)
	end
	if bind_b~=nil then
		if bind_b==1 then
			Bind_to_layer = true
      Layer_is_selected = 1
			if ly_n~=nil then
				if ly_n >= 1 and ly_n <= Max_layer_count then
					Layer_address = ly_n
				end
      else
 -- assign layer 1 if none provided
        Layer_address = 1
			end
		elseif bind_b==0 then
			Bind_to_layer = false
		end
	end
  if ly_n~=nil then
		if ly_n >= 1 and ly_n <= Max_layer_count then
			Layer_address = ly_n
		end
  else
    Layer_address = nil
    Layer_is_selected = nil
	end
	if d_type~=nil then
		if d_type=="enc" or d_type=="abs" then
			for d=1,#Data_type do
				Data_type[d] = d_type
			end
		end
	end
	if i_min~=nil then
		local i_min_fmt = tonumber(i_min)
		if type(i_min_fmt)=="number" then
			for i=1,Surface_input_count do
        if G_names[i]~="Keyboard" then
 -- we assign the default minimum plus the percentage of the default delta value given by the multiplicand of i_min.
  				User_defined_minimum_values[io_n+3+i] = (i_min_fmt*Midi_val_to_unit_interval) * Default_delta_values[io_n+3+i]
          User_defined_delta_values[io_n+3+i] = User_defined_maximum_values[io_n+3+i] - User_defined_minimum_values[io_n+3+i]
          Calculated_unit_interval_scalar_values[io_n+3+i] = (1 / User_defined_delta_values[io_n+3+i])
        end
			end
		end
	end
	if i_max~=nil then
		local i_max_fmt = tonumber(i_max)
		if type(i_max_fmt)=="number" then
			for i=1,Surface_input_count do
        if G_names[i]~="Keyboard" then
  				User_defined_maximum_values[io_n+3+i] = (i_max_fmt*Midi_val_to_unit_interval) * Default_delta_values[io_n+3+i]
          User_defined_delta_values[io_n+3+i] = User_defined_maximum_values[io_n+3+i] - User_defined_minimum_values[io_n+3+i]
          Calculated_unit_interval_scalar_values[io_n+3+i] = (1 / User_defined_delta_values[io_n+3+i])
        end
			end
		end
	end
  if int_c~=nil then
    if int_c >= 1 and int_c <= Midi_max_val+1 then
      for o=1,io_n do
        Interpolation_curve_index[o] = int_c
      end
    end
  end
  if int_s~=nil then
    if int_s >= 1 and int_s <= Midi_max_val+1 then
      for o=1,io_n do
        Interpolation_curve_resolution[o] = int_s
      end
    end
  end
  if o_min~=nil then
    local o_min_fmt = tonumber(o_min)
    if type(o_min_fmt)=="number" then
      for o=1,io_n do
        User_defined_minimum_values[o] = (o_min_fmt*Midi_val_to_unit_interval) * Default_delta_values[o]
        User_defined_delta_values[o] = User_defined_maximum_values[o] - User_defined_minimum_values[o]
        Calculated_unit_interval_scalar_values[o] = (1 / User_defined_delta_values[o])
      end
    end
  end
  if o_max~=nil then
    local o_max_fmt = tonumber(o_max)
    if type(o_max_fmt)=="number" then
      for o=1,io_n do
        User_defined_maximum_values[o] = Default_minimum_values[o] + (o_max_fmt*Midi_val_to_unit_interval) * Default_delta_values[o]
        User_defined_delta_values[o] = User_defined_maximum_values[o] - User_defined_minimum_values[o]
        Calculated_unit_interval_scalar_values[o] = (1 / User_defined_delta_values[o])
      end
    end
  end
end

--[[  parameter editing function, applies only to the parameters specified
      SYNTAX:

           _P("Target Track Enable Automation Recording","ov",128,127,127)

      LEGEND:
			     _P(<data src name>,<io type>,<arg 1>,<arg 2>,<arg 3>)
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

function _P(d_src,io_type,arg_1,arg_2,arg_3)
  local io_n = Surface_input_count * Surface_output_count
  -- local o_n = Surface_output_count
  local n_c = 3
  if d_src~=nil then
    if type(d_src)=="string" then
      io_n = Surface_input_count * Surface_output_count
      local io_idx = nil
      for i,v in ipairs(G_names) do
        if v==d_src then
          io_idx = i
          break
        end
      end
      if Is_midi_controller then
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
                    if arg_1 >= 0 and arg_1 <= Midi_max_val then
                      User_defined_minimum_values[io_n+n_c+io_idx] = (arg_1 * Midi_val_to_unit_interval) * Default_delta_values[io_n+n_c+io_idx]
                      User_defined_delta_values[io_n+n_c+io_idx] = User_defined_maximum_values[io_n+n_c+io_idx] - User_defined_minimum_values[io_n+n_c+io_idx]
                      Calculated_unit_interval_scalar_values[io_n+n_c+io_idx] = (1 / User_defined_delta_values[io_n+n_c+io_idx])
                    end
                  end
                end
                if arg_2~=nil then
                  if type(arg_2)=="number" then
                    if arg_2 >= 0 and arg_2 <= Midi_max_val then
                      User_defined_maximum_values[io_n+n_c+io_idx] = (arg_2 * Midi_val_to_unit_interval) * Default_delta_values[io_n+n_c+io_idx]
                      User_defined_delta_values[io_n+n_c+io_idx] = User_defined_maximum_values[io_n+n_c+io_idx] - User_defined_minimum_values[io_n+n_c+io_idx]
                      Calculated_unit_interval_scalar_values[io_n+n_c+io_idx] = (1 / User_defined_delta_values[io_n+n_c+io_idx])
                    end
                  end
                end
              elseif io_type:sub(2,2)=="t" then
                if arg_1~=nil then
                  if type(arg_1)=="string" then
                    if arg_1=="abs" or arg_1=="enc" then
                      Data_type[io_n+n_c+io_idx] = arg_1
                    end
                  end
                end
              end
            elseif io_type:sub(1,1)=="o" then
              if arg_1~=nil then
                if type(arg_1)=="number" then
                  if arg_1 >= 1 and arg_1 <= Surface_output_count then
                    io_idx = ((io_idx - 1)*Surface_output_count) + arg_1
                    if arg_2~=nil then
                      if type(arg_2)=="number" then
                        if io_type:sub(2,2)=="v" then
                          if arg_2 >= 0 and arg_2 <= Midi_max_val then
                            User_defined_minimum_values[io_idx] = (arg_2 * Midi_val_to_unit_interval) * Default_delta_values[io_idx]
                            User_defined_delta_values[io_idx] = User_defined_maximum_values[io_idx] - User_defined_minimum_values[io_idx]
                            Calculated_unit_interval_scalar_values[io_idx] = (1 / User_defined_delta_values[io_idx])
                          end
                        elseif io_type:sub(2,2)=="i" then
                          if arg_2 >= 1 and arg_2 <= Midi_max_val+1 then
                            Interpolation_curve_index[io_idx] = arg_2
                          end
                        end
                      elseif type(arg_2)=="string" then
                        if io_type:sub(2,2)=="t" then
                          if arg_2=="abs" or arg_2=="enc" then
                            Data_type[io_idx] = arg_2
                          end
                        end
                      end
                    end
                    if arg_3~=nil then
                      if type(arg_3)=="number" then
                        if io_type:sub(2,2)=="v" then
                          if arg_3 >= 0 and arg_2 <= Midi_max_val then
                            User_defined_maximum_values[io_idx] = (arg_3 * Midi_val_to_unit_interval) * Default_delta_values[io_idx]
                            User_defined_delta_values[io_idx] = User_defined_maximum_values[io_idx] - User_defined_minimum_values[io_idx]
                            Calculated_unit_interval_scalar_values[io_idx] = (1 / User_defined_delta_values[io_idx])
                          end
                        elseif io_type:sub(2,2)=="i" then
                          if arg_3 >= 1 and arg_3 <= Midi_max_val+1 then
                            Interpolation_curve_resolution[io_idx] = arg_3
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

          _M(16,1,128,1,0,127)

      ARGUMENTS:
          ch_n    :  1 to 16 --  midi channel
          bind_b  :  0 (false), 1 (true) --  bind to a virtual layer
          ly_n    :  1 to n --  virtual layer address
          k_state :  0 (false), 1 (true) --  enable or disable the master keyboard for this device

          NOTE: The following arguments are safeguarded so that if k_hi goes below k_lo or vise versa,
                the placement of these values in the surface become switched to ensure proper functioning.

          k_lo    :  0 to 127 --  define the lowest key of the keyboard split for this device
          k_hi    :  0 to 127 --  define the highest key of the keyboard split for this device
  ]]

function _M(ch_n,bind_b,ly_n,k_state,k_lo,k_hi)
  if ch_n~=nil and ch_n > 0 and ch_n < 17 then
    Midi_channel = string.sub(Hex(ch_n-1), -1)
  end
  if bind_b~=nil then
    if bind_b==1 then
      Bind_to_layer = true
      Layer_is_selected = 1
 -- if there is no address, look for an assignment
      if Layer_address==nil then
        if ly_n~=nil then
          if ly_n >= 1 and ly_n <= Max_layer_count then
            Layer_address = ly_n
          else
 -- assign layer 1 if none provided
            Layer_address = 1
          end
        end
      end
    elseif bind_b==0 then
      Bind_to_layer = false
    end
  end
  if ly_n~=nil then
    if ly_n >= 1 and ly_n <= Max_layer_count then
      Layer_address = ly_n
    end
  end
  if k_state~=nil then
    if k_state==1 then
      Keyboard_is_enabled = true
    elseif k_state==0 then
      Keyboard_is_enabled = false
    end
  end
  if k_lo~=nil then
    if k_lo >= 0 and k_lo <= Midi_max_val then
      User_defined_minimum_values[Keyboard_index] = k_lo
    end
  end
  if k_hi~=nil then
    if k_hi >= 0 and k_hi <= Midi_max_val then
      User_defined_maximum_values[Keyboard_index] = k_hi
    end
  end
end

--[[  keyboard editing function, applies to all keyboard related variables
      SYNTAX:

          _K(1,0,127)

      ARGUMENTS:
          k_state :  0 (false), 1 (true) --  enable or disable the master keyboard for this device

          NOTE: The following arguments are safeguarded so that if k_hi goes below k_lo or vise versa,
                the placement of these values in the surface become switched to ensure proper functioning.

          k_lo    :  0 to 127 --  lowest key for the keyboard split of this device
          k_hi    :  0 to 127 --  highest key for the keyboard split of this device
  ]]

function _K(k_state,k_lo,k_hi)
  if k_state~=nil then
    if k_state==1 then
      Keyboard_is_enabled = true
    elseif k_state==0 then
      Keyboard_is_enabled = false
    end
  end
  if k_lo~=nil then
    if k_lo >= 0 and k_lo <= Midi_max_val then
      User_defined_minimum_values[Keyboard_index] = k_lo
    end
  end
  if k_hi~=nil then
    if k_hi >= 0 and k_hi <= Midi_max_val then
      User_defined_maximum_values[Keyboard_index] = k_hi
    end
  end
end

function Terminal()
 -- this is where the parsing happens
 -- no data checking, but pre-formatting
  local rgitv = remote.get_item_text_value
  Last_terminal_state = Current_terminal_state
  Current_terminal_state = rgitv(Device_name_command_line_index)
  if Current_terminal_state~=Last_terminal_state then
    local find_func = function(t)
      local func = {"_R", "_Gl", "_P", "_M", "_K"}
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
    local f_type = find_func(Current_terminal_state)
    if f_type~=nil then
      local seek_a,seek_b = find_pars(Current_terminal_state)
      if seek_a~=nil and seek_b~=nil then
        local arg_str = Current_terminal_state:sub(seek_a,seek_b)
        if arg_str:len() >= 1 then
 -- dynamically run the command
---@diagnostic disable-next-line: deprecated
          assert(loadstring(f_type.."("..arg_str..")"))()
        end
      end
    end
  end
end

--[[  End: Terminal   ]]

--[[ BEGIN: Interpolation Engine  ]]

-- ported from Javascript
function Create_shapes()
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
function Create_blends(sh)
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
function Build_interpolation_table()
  local s_obj = Create_shapes()
  local b_obj = Create_blends(s_obj)
  local floor = math.floor
  local i_data = {}
  for my_pointer=0,127 do
    local n = floor((7/127)*my_pointer)
    local pct = ((7/127)*my_pointer) - n
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

function Architect(i_num, o_num, d_in, d_out, m_ch, m_ly)
  local floor = math.floor
  local io_n = i_num * o_num
  Surface_input_count = i_num
  Surface_output_count = o_num

--  Assign core globals for logic structure
  Midi_channel = "?"
  
  if m_ch~=nil and m_ch~="?" then
    Midi_channel = string.sub(Hex(tonumber(m_ch,16)-1), -1)
  end

  Layer_address = m_ly~=nil and m_ly or nil
  Bind_to_layer = Layer_address~=nil and true or false
  Layer_is_selected = Bind_to_layer==true and 1 or nil

  if Is_midi_controller then
 --[[	BUILD MIDI CONTROLLER		]]
 --  Build data structures for virtual outs [1, io_n]
    for vo=1,io_n do
      User_defined_minimum_values[#User_defined_minimum_values+1] = d_out[1]
      Default_minimum_values[#Default_minimum_values+1] = d_out[1]
      User_defined_maximum_values[#User_defined_maximum_values+1] = d_out[2]
      Default_maximum_values[#Default_maximum_values+1] = d_out[2]
      User_defined_delta_values[#User_defined_delta_values+1] = d_out[2] - d_out[1]
      Default_delta_values[#Default_delta_values+1] = d_out[2] - d_out[1]
      Calculated_midpoint_values[#Calculated_midpoint_values+1] = floor((d_out[2] - d_out[1]) * 0.5)
      Calculated_unit_interval_scalar_values[#Calculated_unit_interval_scalar_values+1] =	1
      Item_is_not_editable[#Item_is_not_editable+1] = false
      Current_state[#Current_state+1] = nil
      Last_state[#Last_state+1] = nil
      Data_type[#Data_type+1] = "abs"
      Rotary_encoder_now_ms[#Rotary_encoder_now_ms+1] = nil
      Rotary_encoder_last_ms[#Rotary_encoder_last_ms+1] = nil
      Rotary_encoder_delta_values_ms[#Rotary_encoder_delta_values_ms+1] = nil
      Rotary_encoder_directional_data[#Rotary_encoder_directional_data+1] = nil
    end

    local idx_offset = 1

 --  Build data structures for midi inputs 144 to 239
    for i=1,379 do
      if i==1 then
 -- pitch bend
        table.insert(Input_or_virtual_output_index, "e"..Midi_channel.." xx yy")
        Input_or_virtual_output_index["e"..Midi_channel.." xx yy"] = io_n + idx_offset
        idx_offset = idx_offset + 1
      elseif i==2 then
 -- mod Wheel
        table.insert(Input_or_virtual_output_index, "b"..Midi_channel.." 01 xx")
        Input_or_virtual_output_index["b"..Midi_channel.." 01 xx"] = io_n + idx_offset
        idx_offset = idx_offset + 1
      elseif i==3 then
 -- Expression_index
        table.insert(Input_or_virtual_output_index, "b"..Midi_channel.." 0b xx")
        Input_or_virtual_output_index["b"..Midi_channel.." 0b xx"] = io_n + idx_offset
        idx_offset = idx_offset + 1
      elseif i==4 then
 -- damper Pedal
        table.insert(Input_or_virtual_output_index, "b"..Midi_channel.." 40 xx")
        Input_or_virtual_output_index["b"..Midi_channel.." 40 xx"] = io_n + idx_offset
        idx_offset = idx_offset + 1
      elseif i==5 then
 -- breath
        table.insert(Input_or_virtual_output_index, "b"..Midi_channel.." 02 xx")
        Input_or_virtual_output_index["b"..Midi_channel.." 02 xx"] = io_n + idx_offset
        idx_offset = idx_offset + 1
      elseif (i > 5 and i <= 99) or (i > 107 and i <= 123) then
 -- cc values
        table.insert(Input_or_virtual_output_index, "b"..Midi_channel.." "..Hex(i-6).." xx")
        Input_or_virtual_output_index["b"..Midi_channel.." "..Hex(i-6).." xx"] = io_n + idx_offset
        idx_offset = idx_offset + 1
      elseif i > 123 and i <= 251 then
 -- note velocity
        table.insert(Input_or_virtual_output_index, "9"..Midi_channel.." "..Hex(i-124).." xx")
        Input_or_virtual_output_index["9"..Midi_channel.." "..Hex(i-124).." xx"] = io_n + idx_offset
        idx_offset = idx_offset + 1
      elseif i > 251 and i <= 379 then
 -- note aftertouch
        table.insert(Input_or_virtual_output_index, tostring("a"..Midi_channel.." "..Hex(i-252).." xx"))
        Input_or_virtual_output_index["a"..Midi_channel.." "..Hex(i-252).." xx"] = io_n + idx_offset
        idx_offset = idx_offset + 1
      end
      User_defined_minimum_values[#User_defined_minimum_values+1] = d_in[i].min
      Default_minimum_values[#Default_minimum_values+1] = d_in[i].min
      User_defined_maximum_values[#User_defined_maximum_values+1] = d_in[i].max
      Default_maximum_values[#Default_maximum_values+1] = d_in[i].max
      User_defined_delta_values[#User_defined_delta_values+1] = d_in[i].max - d_in[i].min
      Default_delta_values[#Default_delta_values+1] = d_in[i].max - d_in[i].min
      Calculated_midpoint_values[#Calculated_midpoint_values+1] = floor((d_in[i].max - d_in[i].min) * 0.5)
      Calculated_unit_interval_scalar_values[#Calculated_unit_interval_scalar_values+1] = 1 / (d_in[i].max - d_in[i].min)
      Item_is_not_editable[#Item_is_not_editable+1] = false
      Current_state[#Current_state+1] = 64
      Last_state[#Last_state+1] = 64

      Data_type[#Data_type+1] = "abs"
      Rotary_encoder_now_ms[#Rotary_encoder_now_ms+1] = 0
      Rotary_encoder_last_ms[#Rotary_encoder_last_ms+1] = 0
      Rotary_encoder_delta_values_ms[#Rotary_encoder_delta_values_ms+1] = 0
      Rotary_encoder_directional_data[#Rotary_encoder_directional_data+1] = nil
    end
  else
 --[[	BUILD DEVICE						]]
 --  Build data structures for virtual outs [1, io_n]
    for vo=1,io_n do
      User_defined_minimum_values[#User_defined_minimum_values+1] = d_out[1]
      Default_minimum_values[#Default_minimum_values+1] = d_out[1]
      User_defined_maximum_values[#User_defined_maximum_values+1] = d_out[2]
      Default_maximum_values[#Default_maximum_values+1] = d_out[2]
      User_defined_delta_values[#User_defined_delta_values+1] = d_out[2] - d_out[1]
      Default_delta_values[#Default_delta_values+1] = d_out[2] - d_out[1]
      Calculated_midpoint_values[#Calculated_midpoint_values+1] = floor((d_out[2] - d_out[1]) * 0.5)
      Interpolation_curve_index[#Interpolation_curve_index+1] = 1
      Interpolation_curve_resolution[#Interpolation_curve_resolution+1] = 127
      Calculated_unit_interval_scalar_values[#Calculated_unit_interval_scalar_values+1] = 0 -- blanks, for proper indexing.
      Item_is_not_editable[#Item_is_not_editable+1] = false
      Current_state[#Current_state+1] = nil
      Last_state[#Last_state+1] = nil
    end

 --  Insert blanks for warning message/null items (preserves correct addressing)
    for xx=1,3 do
      User_defined_minimum_values[#User_defined_minimum_values+1] = 0
      Default_minimum_values[#Default_minimum_values+1] = 0
      User_defined_maximum_values[#User_defined_maximum_values+1] = 0
      Default_maximum_values[#Default_maximum_values+1] = 0
      User_defined_delta_values[#User_defined_delta_values+1] = 0
      Default_delta_values[#Default_delta_values+1] = 0
      Calculated_midpoint_values[#Calculated_midpoint_values+1] = 0
      Interpolation_curve_index[#Interpolation_curve_index+1] = 1
      Interpolation_curve_resolution[#Interpolation_curve_resolution+1] = 128 --  stop creating these here, only needed for VO's.
      Calculated_unit_interval_scalar_values[#Calculated_unit_interval_scalar_values+1] = 0
      Item_is_not_editable[#Item_is_not_editable+1] = false
      Current_state[#Current_state+1] = nil
      Last_state[#Last_state+1] = nil
    end

 --  Build data structures for data sources [io_n+4, io_n+i_num]
    for i=1,i_num do
      User_defined_minimum_values[#User_defined_minimum_values+1] = d_in[i].min
      Default_minimum_values[#Default_minimum_values+1] = d_in[i].min
      User_defined_maximum_values[#User_defined_maximum_values+1] = d_in[i].max
      Default_maximum_values[#Default_maximum_values+1] = d_in[i].max
      User_defined_delta_values[#User_defined_delta_values+1] = d_in[i].max - d_in[i].min
      Default_delta_values[#Default_delta_values+1] = d_in[i].max - d_in[i].min
      Calculated_midpoint_values[#Calculated_midpoint_values+1] = d_in[i].min + floor((d_in[i].max - d_in[i].min) * 0.5)
      Calculated_unit_interval_scalar_values[#Calculated_unit_interval_scalar_values+1] = 1 / (d_in[i].max - d_in[i].min)
      Item_is_not_editable[#Item_is_not_editable+1] = false
      Current_state[#Current_state+1] = nil
      Last_state[#Last_state+1] = nil
    end

 --  Build reverse-lookup table to data sources from VO's
 --  Build output indexes relative to data source
    for i=1,i_num do
      for o=1,o_num do
        Input_or_virtual_output_index[#Input_or_virtual_output_index+1] = io_n+3+i
        Virtual_output_source_input_index[#Virtual_output_source_input_index+1] = o
      end
    end

 --[[  Define Interpolation Data   ]]
    Interp_table = Build_interpolation_table()
  end

--  Tell the script the entity loaded properly
  Surface_is_initialized = true
end

-- user input, receives event, last known good (toggle button support)
function User_input(e)
  local rmm=remote.match_midi --  local references to globals
  for m=1,8 do --  look through the possible user input events
    local ui_event=rmm(UI[m], e)
    if ui_event~=nil then --  if we find a match
      if m==6 and ui_event.x==Midi_max_val then --  if this is navigate layers (down)
        if Layer_is_selected~=nil then
          Layer_is_selected = Layer_is_selected-1 --  decrement selected layer
        end
--[[  NOTE: m==6 is an exception to all other user input variations.
                    no latches or states are toggled. ]]
      elseif m==6 and ui_event.x==1 then --  if this is navigate layers (up)
        if Layer_is_selected~=nil then
          Layer_is_selected = Layer_is_selected+1 --  increment selected layer
        end
      else
        if UI[m+8]==0 then --  if the latch is open
          UI[m+16] = not UI[m+16] --  toggle the state
          UI[m+8] = 1 --  close the latch to prevent strobing
        end
      end
    else
      if UI[m+8]==1 then --  if the latch is closed
        UI[m+8] = 0 --  open the latch
      end
    end
  end
end

--  user input, receives event, expects midi gate (except navigate layers)
--[=[function User_input(e)
  local rmm=remote.match_midi --  local references to globals
  for m=1,8 do --  look through the possible user input events
    local ui_event=rmm(UI[m], e)
    if ui_event~=nil then --  if we find a match
      if Layer_is_selected~=nil then --  if we are bound to a layer
        if m==6 then --  if we have detected the layer navigator
          if ui_event.x > 0 then --  if the data contains "1" (counter-clockwise turn)
            Layer_is_selected = Layer_is_selected-1 --  decrement selected layer
          elseif ui_event.x < 1 then --  if the data contains "0" (clockwise turn)
            Layer_is_selected = Layer_is_selected+1 --  increment selected layer
          end
--[[  NOTE: m==6 (navigate layers) is an exception to all other user input variations.
                      No latches or states are toggled.     ]]
        end
      end
      if m~=6 then --  if this is anything other than navigate layers...
        if ui_event.x > 0 then --  if the data contains "1" or higher
          if UI[m+8]==0 then --  if the latch is open
            UI[m+16] = true --  toggle this state to "on"
            UI[m+8] = 1 --  close the latch
          end
        else ui_event.x==0 then --  if the data contains "0"
          if UI[m+8]==1 then --  if the latch is closed
            UI[m+16] = false --  toggle this state to "off"
            UI[m+8] = 0 --  open the latch
          end
        end
      end
    end
  end
end]=]

--  check to see if we are editing
function Editing()
  if UI[20]==true or UI[21]==true or UI[23]==true or UI[24]==true then --  if any of the editing states are toggled "on"
    return true --  say "yes"
  else --  otherwise...
    return false --  say "no"
  end
end

-- audio warp engine
function Warp(p,r)
  -- Prepare the calculated value
  local px = nil
  -- If pitchbend is between -8192 and 0
  if p <= Warp_center_to_min then
    -- Calculate using the "left side" graph
    px = (p - Warp_center_to_min) * Warp_center_to_min_to_unit_interval
  -- Otherwise...
  elseif p > Warp_center_to_min then
    -- Calculate using the "right side" graph
    -- (The math turns out to be identical)
    px = (p - Warp_center_to_min) * Warp_center_to_min_to_unit_interval
  end

  -- Prepare the return value
  local output_data = nil

  -- If the device is not a Combinator
  if Warp_use_24 then
    -- Enforce 24 semitones
    output_data = 4^(r * Warp_24_to_unit_interval * px)
  -- Otherwise...
  else
    -- Use 60 semitones / 10 octaves
    output_data = 4^(60 * Warp_24_to_unit_interval * px)
  end

  -- Return the result
  return output_data
end

-- ignore kb vars, these are data sources that can only update via midi
function Ignore(num)
  if Keyboard_is_enabled and Keyboard_index~=nil then
    if num==Keyboard_index or num==Channel_pressure_index or num==Expression_index or num==Damper_index or num==Breath_index then
      return true
    else
      return false
    end
  end
end

--  allow editing and data flow on certain conditions
function Surface_active()
  if Bind_to_layer==true then
    if Layer_is_selected~=nil and Layer_address~=nil then
      if Layer_is_selected~=Layer_address then
        return false
      elseif Layer_is_selected==Layer_address then
        return true
      end
    end
  else
    return true
  end
end

--[[	Universal Data Write 		]]

-- data write algorithm, receives event
function Write_to_rack(e)
  local rhi=remote.handle_input --  local references to globals
  for i,v in ipairs(Global_midi_batch) do --  look through the contents of Global_midi_batch
    local v_num = tonumber(v) -- convert k to a number so rhi can use it
    local n = Global_midi_batch[v][1] --  retrieve the first LIFO order interpolation value stored in Global_midi_batch for virtual out "k"
    local write_msg = { --  create a data write message to be sent to the rack
      item = v_num, --  apply key "k" as item index
      value = Global_midi_batch[v][n], --  apply retrieved interpolation value as the value for virtual out "k"
      time_stamp = e.time_stamp --  apply event.time_stamp as passed via param "e"
    }
    rhi(write_msg) --  write message to the rack
    if Global_midi_batch[v][1] > 2 then
      Global_midi_batch[v][1] = Global_midi_batch[v][1] - 1
    end
  end
end

--[[	Begin Reason Document		]]

-- reason document write function
function Process_document(event)
  User_input(event) --  process user input first, all processes internal
  if UI[17]==false and Surface_active() then --  if the system has not panicked and the layer is active
 -- if we are editing
    if not Editing() then --  only write to the rack if we are not editing
-- handle note input before any data
      if #Global_midi_batch>0 then --  only proceed if there is anything to process
        Write_to_rack(event) --  write data to the rack
        return true --  tell Reason the events have been used
      end
    end
  end
end

function Detect_warp_engine(i,j)
  -- "i" argument = tempo bpm connected
  -- "j" argument = tempo decimal connected

  local riie = remote.is_item_enabled
  local rgin = remote.get_item_name
  local rgiv = remote.get_item_value
  local warp_state = false

  local bpm_connected = false
  local dec_connected = false

  if i~=nil then
    if riie(i) and rgin(i)~=nil then
      bpm_connected = true
    end
  end

  if j~=nil then
    if riie(j) and rgin(j)~=nil then
      dec_connected = true
    end
  end

  -- If at least one connection is active
  if bpm_connected or dec_connected then
    if bpm_connected then
      -- If there is no last bpm value
      if Warp_from_bpm==nil then
        -- If device type is Combinator
        if Device_type:find("combinator")~=nil then
          -- If project bpm is not 32
          if rgiv(i)~=32 then
            -- Require project bpm to be 32
            Warp_from_bpm = 32
          end
        -- If device is not Combinator
        else
          -- If project bpm is < 4
          if rgiv(i) < 4 then
            -- Require minimum of 4 bpm
            Warp_from_bpm = 4
          -- If project bpm is > 249
          elseif rgiv(i) > 249 then
            -- Require maximum of 249 bpm
            Warp_from_bpm = 249
          -- Otherwise...
          else
            -- Use current project bpm
            Warp_from_bpm = rgiv(i)
          end
        end
        -- Enable warp state
        warp_state = true
      end
    end

    if dec_connected then
      -- If there is no last decimal value
      if Warp_from_dec==nil then
        -- If device is not a Combinator
        if Device_type:find("combinator")==nil then
          -- If max bpm is applied
          if Warp_from_bpm==249 then
            -- If decimal is > 749
            if rgiv(j) > 749 then
              -- Require maximum of 749
              Warp_from_dec = 749
            end
          end
        -- Otherwise...
        else
          -- Allow any decimal value found
          Warp_from_dec = rgiv(j)
        end
        -- Enable warp state
        warp_state = true
      end
    end
  -- If no connection is active
  else
    -- Store the values of i and j in an array
    local chk = {i,j}
    -- Loop through the array
    for ptr=1,2 do
      -- If an item is not nil, reset all related data
      if chk[ptr]~=nil then
        Current_state[chk[ptr]] = nil
        Last_state[chk[ptr]] = nil
        Warp_from_bpm = nil
        Warp_from_dec = nil
        warp_state = false
      end
    end
  end

  -- Prevent NaN for bpm
  if Warp_from_bpm==nil then
    Warp_from_bpm = 120
  end

  -- Prevent NaN for decimal
  if Warp_from_dec==nil then
    Warp_from_dec = 0
  end

  -- Prevent halt condition
  if Warp_from~=nil then
    warp_state = true
  end

  -- If the warp state is enabled
  if warp_state==true then
    -- Calculate default transport speed
    Warp_from = (Warp_from_bpm * 1000) + Warp_from_dec

  -- Otherwise...
  else
    -- Empty the value
    Warp_from = nil
  end

  -- Return true or false
  return warp_state
end

--  checks to see if the device has a pitch bend parameter
function Warp_compatible()
  -- Assume the device can't warp by default
  local can_warp = false

  -- If device controls exist
  if (G_names~=nil) then
    -- Search through the controls
    for i,v in ipairs(G_names) do
      -- If we have found Pitch Bend
      if v:find("Pitch Bend")~=nil then
        -- Confirm the device can warp
        can_warp = true
        -- Stop searching
        break
      end
    end
    -- If the device can warp
    if can_warp then
      -- If this is a Combinator
      if Device_type:find("combinator")~=nil then
        -- Use 60 semitones
        Warp_use_24 = false
      -- Otherwise...
      else
        -- Use 24 semitones
        Warp_use_24 = true
      end
    end
  end

  -- Return the result
  return can_warp
end

--  data read algorithm, receives table "changed_items"
function Read_document(t)
  -- local riie = remote.is_item_enabled
  local rgiv = remote.get_item_value
  -- local rgin = remote.get_item_name
  local floor = math.floor
  -- local o_n = Surface_output_count
  local io_n = Surface_input_count * Surface_output_count

 -- look through changed events
  for i=1,#t do
 -- create local pointer
    local n=t[i]
 -- if we are editing
    if Editing() then
      Current_state[n] = rgiv(n)
      if Current_state[n]~=Last_state[n] then
        if Item_is_not_editable[n]==false then
          if UI[23]==true then -- min
            User_defined_minimum_values[n] = rgiv(n)
            User_defined_delta_values[n] = User_defined_maximum_values[n] - User_defined_minimum_values[n]
            Calculated_midpoint_values[n] = User_defined_minimum_values[n] + floor(User_defined_minimum_values[n] + (User_defined_delta_values[n] * 0.5))
          end
          if UI[24]==true then -- max
            User_defined_maximum_values[n] = rgiv(n)
            User_defined_delta_values[n] = User_defined_maximum_values[n] - User_defined_minimum_values[n]
            Calculated_midpoint_values[n] = User_defined_minimum_values[n] + floor(User_defined_minimum_values[n] + (User_defined_delta_values[n] * 0.5))
          end
        end
        Last_state[n] = Current_state[n]
      end
      if n>(io_n+3) then --  ratios for data sources only
        if Item_is_not_editable[n]==false then
          Calculated_unit_interval_scalar_values[n] = 1 / User_defined_delta_values[n]
        end
      elseif n<=io_n then
        if UI[20]==true then --  curve edit
          local c_val = floor((rgiv(n)-User_defined_minimum_values[n])*Calculated_unit_interval_scalar_values[n])
          Interpolation_curve_index[n] = floor(c_val * Midi_max_val)+1
        end
        if UI[21]==true then --  step edit
          local s_val = floor((rgiv(n)-User_defined_minimum_values[n])*Calculated_unit_interval_scalar_values[n])
          Interpolation_curve_resolution[n] = floor(s_val * Midi_max_val)+1
        end
      end
 -- if we are not editing
    else
 -- default behavior
      if n>(io_n+3) then
        Batch_doc(n)
      end
    end
  end
end

function Batch_doc(n)
  local floor = math.floor
  local riie = remote.is_item_enabled
  local rgiv = remote.get_item_value
  -- local rgin = remote.get_item_name
  -- local ignore = Ignore
  local o_n = Surface_output_count
  local io_n = Surface_input_count * Surface_output_count

  if riie(n) then --  only proceed if surface is locked
    local float = nil
    if UI[18]==true then --  if we are in bipolar mode
      float = (rgiv(n) - Calculated_midpoint_values[n]) * (Calculated_unit_interval_scalar_values[n] * 0.5) --  precalculate the float value in the range [-1,	1]
      float = float >= -1 and float or -1 --  conditionally constrain the floor of the float value to -1
      float = float <= 1 and float or 1 --  conditionally constrain the ceiling of the float value to 1
    else --  if we are in unipolar mode
      float = (rgiv(n) - User_defined_minimum_values[n]) * Calculated_unit_interval_scalar_values[n] --  precalculate the float value in the range [0,		1]
      float = float >= 0 and float or 0 --  conditionally constrain the floor of the float value to 0
      float = float <= 1 and float or 1 --  conditionally constrain the ceiling of the float value to 1
    end

    local n2 = n - (io_n+3) --  reformat n to point to the virtual outs of the data source

    local o1=((n2-1)*o_n)+1 --  create the lower bound of the virtual outs
    local o2=(n2*o_n) --  create the upper bound of the virtual outs

    for o=o1,o2 do
      if riie(o) then -- only proceed if the output is connected
        local o_str = tostring(o)
        if Global_midi_batch[o_str] == nil then table.insert(Global_midi_batch, o_str) end

        Global_midi_batch[o_str] = {2}

        local dy1 = rgiv(o) --  extract the current position of virtual out "o"
        local dy2 = nil

        if UI[18]==true then
          dy2 = floor(Calculated_midpoint_values[o] + (float * (User_defined_delta_values[o] * 0.5)))
        else
          dy2 = floor(User_defined_minimum_values[o] + (float * User_defined_delta_values[o]))
        end

        local dy = dy2 - dy1 --  store the difference between the two positions
        local px = Interpolation_curve_index[o] * (Midi_max_val+1) --  create a pointer to the interpolation curve variation

        for cr=Midi_max_val+1, Interpolation_curve_resolution[o], -Interpolation_curve_resolution[o] do --  retrieve data entries stored within curve "px"
          Global_midi_batch[o_str][#Global_midi_batch[o_str]+1] = floor(dy1 + (Interp_table[px+cr] * dy)) --  store the curve data in reverse order
        end

        Global_midi_batch[o_str][1] = #Global_midi_batch[o_str]

      end
    end
  end
end

-- reason document set state
function Set_document(changed_items)
  if UI[17]==false and Surface_active() then
    if type(changed_items)=="table" then
      if #changed_items>0 then
        Read_document(changed_items)
      end
    end
  end
end

--[[	End Reason Document		]]


--[[	////////////////////	]]


--[[	Begin Data network		]]

-- data network write function
function Process_network(event)
  local rmm = remote.match_midi
  local rhi = remote.handle_input
  local format = string.format

  User_input(event) --  process user input first, all processes internal
  if UI[17]==false and Surface_active() then --  if the system has not panicked and the layer is active
 -- if we are editing
    if Editing() then
 -- if the keyboard is enabled
      if Keyboard_is_enabled and Keyboard_index~=nil then
        local ne_fmt = Midi_channel~="?" and format("%x",(Midi_channel-1)) or Midi_channel
        local ne_event = rmm("<100x>"..ne_fmt.." yy zz", event)
 -- if a note has been detected
        if ne_event~=nil then
 -- edit lo key
          if UI[23] then
 -- only apply edits when keys are pressed
            if ne_event.x > 0 then
              User_defined_minimum_values[Keyboard_index] = ne_event.y
 -- auto-correct keyboard splits
              if User_defined_minimum_values[Keyboard_index] > User_defined_maximum_values[Keyboard_index] then
                local temp_hi = User_defined_maximum_values[Keyboard_index]
                User_defined_minimum_values[Keyboard_index] = User_defined_maximum_values[Keyboard_index]
                User_defined_maximum_values[Keyboard_index] = temp_hi
              end
              User_defined_delta_values[Keyboard_index] = User_defined_maximum_values[Keyboard_index] - User_defined_minimum_values[Keyboard_index]
              Calculated_unit_interval_scalar_values[Keyboard_index] = 1 / User_defined_delta_values[Keyboard_index]
            end
 -- play the note to allow for user confirmation by ear
            local lo_msg = {
              item = Keyboard_index,
              value = ne_event.x,
              note = ne_event.y,
              velocity = ne_event.z,
              time_stamp= event.time_stamp
            }
            rhi(lo_msg)
          end
 -- edit hi key
          if UI[24] then
            if ne_event.x > 0 then
              User_defined_maximum_values[Keyboard_index] = ne_event.y
              if User_defined_maximum_values[Keyboard_index] < User_defined_minimum_values[Keyboard_index] then
                local temp_lo = User_defined_minimum_values[Keyboard_index]
                User_defined_maximum_values[Keyboard_index] = User_defined_minimum_values[Keyboard_index]
                User_defined_minimum_values[Keyboard_index] = temp_lo
              end
              User_defined_delta_values[Keyboard_index] = User_defined_maximum_values[Keyboard_index] - User_defined_minimum_values[Keyboard_index]
              Calculated_unit_interval_scalar_values[Keyboard_index] = 1 / User_defined_delta_values[Keyboard_index]
            end
            local hi_msg = {
              item = Keyboard_index,
              value = ne_event.x,
              note = ne_event.y,
              velocity = ne_event.z,
              time_stamp= event.time_stamp
            }
            rhi(hi_msg)
          end
        end
      end
    else --  only write to the rack if we are not editing
-- handle note input before any data
      if Keyboard_is_enabled and Keyboard_index~=nil then
        local ch_fmt = Midi_channel~="?" and format("%x",Midi_channel) or Midi_channel
        local nt_event = rmm("<100x>"..ch_fmt.." yy zz", event)
        if nt_event~=nil then
          if nt_event.y >= User_defined_minimum_values[Keyboard_index] and nt_event.y <= User_defined_maximum_values[Keyboard_index] then
            local nt_msg = {
              item = Keyboard_index,
              value = nt_event.x,
              note = nt_event.y,
              velocity = nt_event.z,
              time_stamp= event.time_stamp
            }

            rhi(nt_msg)
            Batch_midi(nt_event.y, Keyboard_index)
          end
        end
        local pb_event = rmm("e"..ch_fmt.." xx yy", event)
        if pb_event~=nil then
          local pb_msg = {
            item = Pitch_bend_index,
            value = pb_event.y*128+pb_event.x,
            time_stamp= event.time_stamp
          }
          rhi(pb_msg)
 --batch_midi(pb_msg.value, Pitch_bend_index) --  this is causing a problem with the warp engine
        end
--[[
        local md_event = rmm("b"..ch_fmt.." 01 xx", event)
        if md_event~=nil then
          local md_msg = {
            item = Modulation_wheel_index,
            value = md_event.x,
            time_stamp= event.time_stamp
          }
          rhi(md_msg)
        end
        local ch_event = rmm("d"..ch_fmt.." xx", event)
        if ch_event~=nil then
          local ch_msg = {
            item = Channel_pressure_index,
            value = ch_event.x,
            time_stamp= event.time_stamp
          }
          rhi(ch_msg)
          batch_midi(ch_event.x, Channel_pressure_index)
        end
        local ex_event = rmm("b"..ch_fmt.." 0b xx", event)
        if ex_event~=nil then
          local ex_msg = {
            item = Expression_index,
            value = ex_event.x,
            time_stamp= event.time_stamp
          }
          rhi(ex_msg)
          batch_midi(ex_event.x, Expression_index)
        end
        local dp_event = rmm("b"..ch_fmt.." 40 xx", event)
        if dp_event~=nil then
          local dp_msg = {
            item = Damper_index,
            value = dp_event.x,
            time_stamp= event.time_stamp
          }
          rhi(dp_msg)
          batch_midi(dp_event.x, Damper_index)
        end
        local br_event = rmm("b"..ch_fmt.." 02 xx", event)
        if br_event~=nil then
          local br_msg = {
            item = Breath_index,
            value = br_event.x,
            time_stamp= event.time_stamp
          }
          rhi(br_msg)
          batch_midi(br_event.x, Breath_index)
        end]]
      end
      if #Global_midi_batch>0 then --  only proceed if there is anything to process
        Write_to_rack(event) --  write data to the rack
        return true --  tell Reason the events have been used
      end
    end
  end
end

--  data read algorithm, receives table "changed_items"
function Read_network(t)
  local riie = remote.is_item_enabled
  local rgiv = remote.get_item_value
  local rgin = remote.get_item_name
  local floor = math.floor
  local o_n = Surface_output_count
  local io_n = Surface_input_count * Surface_output_count

  for i=1,#t do
    local n=t[i]
    if n==Device_name_command_line_index then
      Terminal()
    else
--  if we are editing
      if Editing() then
        Current_state[n] = rgiv(n)
        if Current_state[n]~=Last_state[n] then
          if Item_is_not_editable[n]==false then
            if UI[23]==true then
              User_defined_minimum_values[n] = rgiv(n)
              User_defined_delta_values[n] = User_defined_maximum_values[n] - User_defined_minimum_values[n]
              Calculated_midpoint_values[n] = User_defined_minimum_values[n] + floor(User_defined_minimum_values[n] + (User_defined_delta_values[n] * 0.5))
            end
            if UI[24]==true then
              User_defined_maximum_values[n] = rgiv(n)
              User_defined_delta_values[n] = User_defined_maximum_values[n] - User_defined_minimum_values[n]
              Calculated_midpoint_values[n] = User_defined_minimum_values[n] + floor(User_defined_minimum_values[n] + (User_defined_delta_values[n] * 0.5))
            end
          end
          if n>(io_n+3) then --  ratios for data sources only
            if Item_is_not_editable[n]==false then
              Calculated_unit_interval_scalar_values[n] = 1 / User_defined_delta_values[n]
            end
          elseif n<=io_n then
            if UI[20]==true then --  curve edit
              local c_val = floor((rgiv(n)-User_defined_minimum_values[n])*Calculated_unit_interval_scalar_values[n])
              Interpolation_curve_index[n] = floor(c_val * Midi_max_val)+1
            end
            if UI[21]==true then --  step edit
              local s_val = floor((rgiv(n)-User_defined_minimum_values[n])*Calculated_unit_interval_scalar_values[n])
              Interpolation_curve_resolution[n] = floor(s_val * Midi_max_val)+1
            end
          end
          Last_state[n] = Current_state[n]
        end
--  if we are not editing
      else
        if Has_pitch_wheel then --  if this device contains pitch bend
          if W1_index~=nil or W2_index~=nil then
            Warp_is_enabled = Detect_warp_engine(W1_index, W2_index) --  enable warp calculations if either or both of the bpm/decimal outputs are connected
          end
        end
        if Warp_is_enabled then --  if the warp calculations are enabled
          if Warp_from~=nil then --  double check to make sure Warp_from exists
            local warp_output = nil --  create placeholder for the warp output
            if Warp_use_24 then --  if we are using 24 semitones from an instrument
              warp_output = (Warp(rgiv(Pitch_bend_index), rgiv(Pitch_bend_range_index)) * Warp_from) --  calculate using pitch bend and pitch bend range
            else
              warp_output = (Warp(rgiv(Pitch_bend_index), nil) * Warp_from) --  otherwise, calculate using only pitch
            end
            Warp_send_bpm = Round(warp_output * 0.001, 0) --  format the bpm message as 1/1000th of the result given by warp()
            Warp_send_dec = Round(warp_output - (Warp_send_bpm * 1000), 0) --  calculate the decimal message based on bpm
          end
        end
 -- generate batches from data sources
        if n>(io_n+3) then
          Batch_net(n)
        end
      end
    end
  end
end

-- read the value of a parameter and generate an interpolation batch
function Batch_net(n)
  local floor = math.floor
  local riie = remote.is_item_enabled
  local rgiv = remote.get_item_value
  local rgin = remote.get_item_name
  local ignore = Ignore
  local o_n = Surface_output_count
  local io_n = Surface_input_count * Surface_output_count

  if riie(n) then --  only proceed if surface is locked
    if not ignore(n) then -- only proceed if this is not an item that requires midi input to function
      local float = nil
      if UI[18]==true then --  if we are in bipolar mode
        float = (rgiv(n) - Calculated_midpoint_values[n]) * (Calculated_unit_interval_scalar_values[n] * 0.5) --  precalculate the float value in the range [-1,	1]
        float = float >= -1 and float or -1 --  conditionally constrain the floor of the float value to -1
        float = float <= 1 and float or 1 --  conditionally constrain the ceiling of the float value to 1
      else --  if we are in unipolar mode
        float = (rgiv(n) - User_defined_minimum_values[n]) * Calculated_unit_interval_scalar_values[n] --  precalculate the float value in the range [0,		1]
        float = float >= 0 and float or 0 --  conditionally constrain the floor of the float value to 0
        float = float <= 1 and float or 1 --  conditionally constrain the ceiling of the float value to 1
      end

      local n2 = n - (io_n+3) --  reformat n to point to the virtual outs of the data source

      local o1=((n2-1)*o_n)+1 --  create the lower bound of the virtual outs
      local o2=(n2*o_n) --  create the upper bound of the virtual outs
      for o=o1,o2 do
        if riie(o) then
          local o_str = tostring(o)
          if Global_midi_batch[o_str] == nil then table.insert(Global_midi_batch, o_str) end
          Global_midi_batch[o_str] = {2}
          local dy1 = rgiv(o) --  extract the current position of virtual out "o"
          local dy2 = nil

          if W1_index~=nil and o==W1_index then
            if Warp_send_bpm~=nil then
              dy2 = Warp_send_bpm
            else
              dy2 = dy1
            end
          elseif W2_index~=nil and o==W2_index then
            if Warp_send_dec~=nil then
              dy2 = Warp_send_dec
            else
              dy2 = dy1
            end
          else
            if UI[18]==true then
              dy2 = floor(Calculated_midpoint_values[o] + (float * (User_defined_delta_values[o] * 0.5)))
            else
              dy2 = floor(User_defined_minimum_values[o] + (float * User_defined_delta_values[o]))
            end
          end

          local dy = dy2 - dy1 --  store the difference between the two positions
          local px = Interpolation_curve_index[o] * (Midi_max_val+1) --  create a pointer to the interpolation curve variation (i think this is correct)

          for cr=Midi_max_val+1, Interpolation_curve_resolution[o], -Interpolation_curve_resolution[o] do --  retrieve data entries stored within curve "px"
            Global_midi_batch[o_str][#Global_midi_batch[o_str]+1] = floor(dy1 + (Interp_table[px+cr] * dy)) --  store the curve data in reverse order
          end
          Global_midi_batch[o_str][1] = #Global_midi_batch[o_str]
        end
      end
    end
  end
end

-- data network set state
function Set_network(changed_items)
  if UI[17]==false and Surface_active() then --  if the system has not panicked
    if type(changed_items)=="table" then
      if #changed_items>0 then --  only proceed if there is something to process
        Read_network(changed_items) --  read from the changed items, for loop internal
      end
    end
  end
end

--[[	End Data network		]]


--[[	//////////////////	]]


-- -- BEGIN MIDI CONTROLLER SECTION -- --


--[[	LEGACY CODE
function Build_midi_decay()
  local log = math.log
  local huge = math.huge
  local x = 0
  local n = nil
  local s = nil
  local g = 0
  local out = nil
 -- increment through the data set
  for x=0,127 do
    segment[#segment+1] = #decay+1
    if x==0 then
      decay[#decay+1] = 0
    else
 -- calculate the scale of the curve at this x value
      s = (log(1+(x*(10/127))))*(1/(log(11)))
 -- determine if left side or right side graphs are needed
      if x < 64 then
        n = (2048/4097)*((x - 64)^2)+1
      elseif x >= 64 then
        n = (63/3970)*((x - 64)^2)+1
      end
 -- initialize vars
      g = 0
      out = nil
 -- graph the curve
      while tostring(out).sub(1,3)~="0.0" do
        if x < 64 then
          out = (126/127)^(g*n)
        elseif x >= 64 then
          out = (126/127)^(g/n)
        end
        decay[#decay+1] = out * s
        g = g+1
      end
    end
  end
end
]]

-- variable speed response for rotary encoders, output ranging from 127 to 1.
-- output will return a negative value within the given range if dir = 1
function Rotary_speed(ms, dir)
  local floor = math.floor -- local refs to globals
  local Rotary_encoder_minimum_ms = Rotary_encoder_minimum_ms
  local Rotary_encoder_maximum_ms = Rotary_encoder_maximum_ms
  local rs_a = 0.00220482283294 -- folded constant, 127 / 57601
  ms = ms < Rotary_encoder_minimum_ms and Rotary_encoder_minimum_ms or ms
  ms = ms > Rotary_encoder_maximum_ms and Rotary_encoder_maximum_ms or ms
  local rate = math.floor(rs_a * ((ms-Rotary_encoder_maximum_ms)*(ms-Rotary_encoder_maximum_ms)) + 1)
  rate = (dir>0) and (rate*(-1)) or rate
  return rate
end

function Process_controller(event)
  local rmm = remote.match_midi
  local rhi = remote.handle_input
  local riie = remote.is_item_enabled
  local rgiv = remote.get_item_value
  local rgtm = remote.get_time_ms
  local format = string.format
  local o_n = Surface_output_count
  local io_n = Surface_input_count * Surface_output_count

 -- handle user inputs first above anything else
  User_input(event)

 -- detect midi handling exception(s) that may vary over time
  local do_midi = true
  if Bind_to_layer==true then
    if Layer_is_selected~=nil and Layer_address~=nil then
      if Layer_is_selected~=Layer_address then
        do_midi = false
      end
    end
  end
 -- if we are able to proceed, get on with it
  if UI[17]==false and do_midi then
 -- look for the clock signal
    local _clock = rmm(Clock_mask, event)
 -- if this is something other than clock signal
    if _clock==nil then
 -- find out what it is
      local m_event = rmm("xx yy zz", event)
 -- and make sure we found it
      if m_event~=nil then
 -- create a placeholder for the index pointer
        local idx_n = nil

 -- extract and convert numbers to Hex
        local x_byte = Hex(m_event.x)
        local y_byte = Hex(m_event.y)
        local ctrl_fmt = Midi_channel~="?" and format("%x", (Midi_channel-1)) or Midi_channel

        local is_pitch = false
        if m_event.x > 143 and m_event.x <= 159 then -- look for "90" thru "9f"
          x_byte = x_byte:sub(1,1).."?"
          idx_n = Input_or_virtual_output_index[x_byte.." "..y_byte.." xx"]
        elseif m_event.x > 159 and m_event.x <= 175 then -- look for "a0" thru "af"
          x_byte = x_byte:sub(1,1).."?"
          idx_n = Input_or_virtual_output_index[x_byte.." "..y_byte.." xx"]
        elseif m_event.x > 175 and m_event.x <= 191 then -- look for "b0" thru "bf"
          x_byte = x_byte:sub(1,1).."?"
          idx_n = Input_or_virtual_output_index[x_byte.." "..y_byte.." xx"]
        elseif m_event.x > 223 and m_event.x <= 239 then -- look for "e0" thru "ef"
 -- ignore y because this is a pitch bend
          idx_n = Input_or_virtual_output_index[x_byte.." xx yy"]
        end
 -- if we have found an index we can use for this data
        if idx_n~=nil then
          local m_data = 0 -- placeholders
          local is_encoder = false
          if idx_n==Pitch_bend_index then
 -- create pitch bend data
            m_data = -8192+((m_event.z*(Midi_max_val+1))+m_event.y)
            is_pitch = true
          else
            if Data_type[idx_n]=="enc" then
              local enc_data = rmm(x_byte:sub(1,1)..ctrl_fmt.." "..y_byte.." <???y>x", event)
              if enc_data~=nil then
                Rotary_encoder_last_ms[idx_n] = Rotary_encoder_now_ms[idx_n]
                Rotary_encoder_now_ms[idx_n] = rgtm()
                Rotary_encoder_delta_values_ms[idx_n] = Rotary_encoder_last_ms[idx_n]==nil and Rotary_encoder_maximum_ms or Rotary_encoder_now_ms[idx_n] - Rotary_encoder_last_ms[idx_n]
                Rotary_encoder_directional_data[idx_n] = enc_data.y
                is_encoder = true
              end
            else
 -- create standard midi data
              m_data = m_event.z
            end
          end
 -- process rotary encoders
          if is_encoder and idx_n~=nil and Current_state[idx_n]~=nil then
 -- process data flow
 -- define changed state
            Last_state[idx_n] = Current_state[idx_n]
            Current_state[idx_n] = (Current_state[idx_n] + Rotary_speed(Rotary_encoder_delta_values_ms[idx_n], Rotary_encoder_directional_data[idx_n]))
            Current_state[idx_n] = Current_state[idx_n] < 0 and 0 or Current_state[idx_n]
            Current_state[idx_n] = Current_state[idx_n] > Midi_max_val and Midi_max_val or Current_state[idx_n]

 -- only if something has changed for this input do we proceed
            if Current_state[idx_n]~=Last_state[idx_n] then
 -- define float
              local e_float=nil

              if Editing() then
                e_float = ((Current_state[idx_n] - Default_minimum_values[idx_n])*(1 / Default_delta_values[idx_n]))
              else
                e_float = ((Current_state[idx_n] - User_defined_minimum_values[idx_n])*Calculated_unit_interval_scalar_values[idx_n])
              end

 -- constrain to unit interval [0,1]
              e_float = e_float < 0 and 0 or e_float
              e_float = e_float > 1 and 1 or e_float
 -- define virtual outputs
              local eo1 = (((idx_n-io_n)-1)*o_n)+1
              local eo2 = o_n < 2 and eo1 or (eo1+(o_n-1))
 -- seek out connected outputs
              for eo=eo1,eo2 do
 -- apply manipulations to them
                if riie(eo) then
                  local eo_data = nil

                  if Editing() then
                    eo_data = Default_minimum_values[eo] + (e_float * Default_delta_values[eo])
                  else
                    eo_data = User_defined_minimum_values[eo] + (e_float * User_defined_delta_values[eo])
                  end

                  local eo_packet = {
                    item=eo,
                    value=eo_data,
                    time_stamp=event.time_stamp
                  }
                  rhi(eo_packet)
                end
              end
              return true
            end
 -- process standard midi inputs
          else
 -- process data flow
 -- define changed state
            Last_state[idx_n] = Current_state[idx_n]
            Current_state[idx_n] = m_data
            Current_state[idx_n] = (Current_state[idx_n] < 0) and 0 or Current_state[idx_n]
            Current_state[idx_n] = (Current_state[idx_n] > Midi_max_val) and Midi_max_val or Current_state[idx_n]
 -- only if something has changed do we proceed
            if Current_state[idx_n]~=Last_state[idx_n] then
 -- define float
              local float = nil

              if Editing() then
                float = (m_data - Default_minimum_values[idx_n])*(1 / Default_delta_values[idx_n])
              else
                float = (m_data - User_defined_minimum_values[idx_n])*Calculated_unit_interval_scalar_values[idx_n]
              end

 -- constrain to unit interval [0,1]
              float = float < 0 and 0 or float
              float = float > 1 and 1 or float
 -- define virtual outputs
              local o1 = (((idx_n-io_n)-1)*o_n)+1
              local o2 = o_n < 2 and o1 or (o1+(o_n-1))
 -- seek out connected outputs
              for o=o1,o2 do
                if riie(o) then
 -- apply manipulations to them
                  local o_data = nil

                  if Editing() then
                    o_data = Default_minimum_values[o] + (float * Default_delta_values[o])
                  else
                    o_data = User_defined_minimum_values[o] + (float * User_defined_delta_values[o])
                  end

                  local o_packet = {
                    item=o,
                    value=o_data,
                    time_stamp=event.time_stamp
                  }
                  rhi(o_packet)
                end
              end
              return true
            end
          end
        end
      end
    end
  end
end

-- read a midi value and generate an interpolation batch
function Batch_midi(h, n)
  local floor = math.floor
  local riie = remote.is_item_enabled
  local rgiv = remote.get_item_value
  local o_n = Surface_output_count
  local io_n = Surface_input_count * Surface_output_count

  local float = nil
  if UI[18]==true then --  if we are in bipolar mode
    float = (h - Calculated_midpoint_values[n]) * (Calculated_unit_interval_scalar_values[n] * 0.5) --  precalculate the float value in the range [-1,	1]
    float = float >= -1 and float or -1 --  conditionally constrain the floor of the float value to -1
    float = float <= 1 and float or 1 --  conditionally constrain the ceiling of the float value to 1
  else --  if we are in unipolar mode
    float = (h - User_defined_minimum_values[n]) * Calculated_unit_interval_scalar_values[n] --  precalculate the float value in the range [0,		1]
    float = float >= 0 and float or 0 --  conditionally constrain the floor of the float value to 0
    float = float <= 1 and float or 1 --  conditionally constrain the ceiling of the float value to 1
  end

  local n2= n - (io_n+3) --  reformat n to point to the virtual outs of the data source

  local o1=((n2-1)*o_n)+1 --  create the lower bound of the virtual outs
  local o2=(n2*o_n) --  create the upper bound of the virtual outs
  for o=o1,o2 do
    local o_str = tostring(o)
    if Global_midi_batch[o_str] == nil then table.insert(Global_midi_batch, o_str) end
    Global_midi_batch[o_str] = {2}
    local dy1 = rgiv(o) --  extract the current position of virtual out "o"
    local dy2 = nil
    if UI[18]==true then
      dy2 = floor(Calculated_midpoint_values[o] + (float * (User_defined_delta_values[o] * 0.5)))
    else
      dy2 = floor(User_defined_minimum_values[o] + (float * User_defined_delta_values[o]))
    end
    local dy = dy2 - dy1 --  store the difference between the two positions
    local px = Interpolation_curve_index[o] * (Midi_max_val+1) --  create a pointer to the interpolation curve variation (i think this is correct)
    for cr=Midi_max_val+1, Interpolation_curve_resolution[o], -Interpolation_curve_resolution[o] do --  retrieve data entries stored within curve "px"
      Global_midi_batch[o_str][#Global_midi_batch[o_str]+1] = floor(dy1 + (Interp_table[px+cr] * dy)) --  store the curve data in reverse order
    end
    Global_midi_batch[o_str][1] = #Global_midi_batch[o_str]
  end
end

-- midi controller set state
function Set_controller(changed_items)
  if UI[17]==false and Surface_active() then
    if type(changed_items)=="table" then
      if #changed_items>0 then
        Read_controller(changed_items)
      end
    end
  end
end

function Read_controller(t)
  local riie = remote.is_item_enabled
  local rgiv = remote.get_item_value
  local floor = math.floor
  local o_n = Surface_output_count
  local io_n = Surface_input_count * Surface_output_count
  for i=1,#t do
    local n=t[i]
    if riie(n) then
      if n==Device_name_command_line_index then
        Terminal()
      elseif n<=io_n then
 --  if we are editing
        if Editing() then
          Current_state[n] = rgiv(n)
          if Current_state[n]~=Last_state[n] then
            if UI[23]==true then
              User_defined_minimum_values[n] = rgiv(n)
              User_defined_delta_values[n] = User_defined_maximum_values[n] - User_defined_minimum_values[n]
              Calculated_midpoint_values[n] = User_defined_minimum_values[n] + floor(User_defined_minimum_values[n] + (User_defined_delta_values[n] * 0.5))
            end
            if UI[24]==true then
              User_defined_maximum_values[n] = rgiv(n)
              User_defined_delta_values[n] = User_defined_maximum_values[n] - User_defined_minimum_values[n]
              Calculated_midpoint_values[n] = User_defined_minimum_values[n] + floor(User_defined_minimum_values[n] + (User_defined_delta_values[n] * 0.5))
            end
            Last_state[n] = Current_state[n]
          end
        end
      end
    end
  end
end

-- -- END MIDI CONTROLLER SECTION  -- --
_G["Define_reason_master_section"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Inserts Pre"
  names[#names+1] = "Rotary 1"
  names[#names+1] = "Rotary 2"
  names[#names+1] = "Rotary 3"
  names[#names+1] = "Rotary 4"
  names[#names+1] = "Button 1"
  names[#names+1] = "Button 2"
  names[#names+1] = "Button 3"
  names[#names+1] = "Button 4"
  names[#names+1] = "To Insert FX Peak Meter"
  names[#names+1] = "From Insert FX Peak Meter"
  names[#names+1] = "Threshold"
  names[#names+1] = "Ratio"
  names[#names+1] = "Attack"
  names[#names+1] = "Release"
  names[#names+1] = "Make-Up Gain"
  names[#names+1] = "Compressor On"
  names[#names+1] = "Key On"
  names[#names+1] = "Gain Reduction"
  for f=1,8 do
    names[#names+1] = "FX"..f.." Send Level Meter"
    names[#names+1] = "FX"..f.." Send Level"
    names[#names+1] = "FX"..f.." Return Level Meter"
    names[#names+1] = "FX"..f.." Return Level"
    names[#names+1] = "FX"..f.." Pan"
    names[#names+1] = "FX"..f.." Mute"
  end
  names[#names+1] = "Dim -20dB"
  names[#names+1] = "Master Level Meter Left"
  names[#names+1] = "Master Level Meter Right"
  names[#names+1] = "Master Level Left Peak"
  names[#names+1] = "Master Level Right Peak"
  names[#names+1] = "Clip Indicator Left"
  names[#names+1] = "Clip Indicator Right"
  names[#names+1] = "Ctrl Room Source"
  names[#names+1] = "Ctrl Room FX Select"
  names[#names+1] = "Ctrl Room Level"
  names[#names+1] = "Bypass Insert FX"
  names[#names+1] = "Master Level"
  names[#names+1] = "Inserts Connected"
  names[#names+1] = "All Mutes Off"
  names[#names+1] = "All Solo Off"
  names[#names+1] = "Reset Clip"
  names[#names+1] = "Remote Base Channel"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=1} -- inserts pre
  data[#data+1] = {min=0, max=127} -- rotary 1 - 4
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1} -- button 1 - 4
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20} -- to/from insert fx peak meter
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=127} -- threshold
  data[#data+1] = {min=0, max=2} -- ratio
  data[#data+1] = {min=0, max=5} -- attack
  data[#data+1] = {min=0, max=4} -- release
  data[#data+1] = {min=0, max=127} -- make-up gain
  data[#data+1] = {min=0, max=1} -- compressor on
  data[#data+1] = {min=0, max=1} -- key on
  data[#data+1] = {min=0, max=20} -- gain reduction
  for f=1,8 do
    data[#data+1] = {min=0, max=20} -- fx 'f' send level meter
    data[#data+1] = {min=0, max=127} -- fx 'f' send level
    data[#data+1] = {min=0, max=20} -- fx 'f' return level meter
    data[#data+1] = {min=0, max=127} -- fx 'f' return level
    data[#data+1] = {min=-100, max=100} -- fx 'f' pan
    data[#data+1] = {min=0, max=1} -- fx 'f' mute
  end
  data[#data+1] = {min=0, max=1} -- dim -20db
  data[#data+1] = {min=0, max=32} -- master level meter left
  data[#data+1] = {min=0, max=32} -- master level meter right
  data[#data+1] = {min=0, max=32} -- master level left peak
  data[#data+1] = {min=0, max=32} -- master level right peak
  data[#data+1] = {min=0, max=1} -- clip indicator left
  data[#data+1] = {min=0, max=1} -- clip indicator right
  data[#data+1] = {min=0, max=2} -- ctrl room source
  data[#data+1] = {min=0, max=7} -- ctrl room fx select
  data[#data+1] = {min=0, max=127} -- ctrl room level
  data[#data+1] = {min=0, max=1} -- bypass insert fx
  data[#data+1] = {min=0, max=1000} -- master level
  data[#data+1] = {min=0, max=1} -- inserts connected
  data[#data+1] = {min=0, max=1} -- all mutes off
  data[#data+1] = {min=0, max=1} -- all solo off
  data[#data+1] = {min=0, max=1} -- reset clip
  data[#data+1] = {min=1, max=128} -- remote base channel

-- if we want this device type to have its own output count
  if (_G["Master_section_outputs"]~=nil) and (_G["Master_section_outputs"]>=1) then
-- assign it here
    out_count = _G["Master_section_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
    Has_pitch_wheel = Warp_compatible()
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_reason_main_mixer"] = function()
  local rdi = remote.define_items
  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}

  names[#names+1] = "Inserts Pre"
  names[#names+1] = "Rotary 1"
  names[#names+1] = "Rotary 2"
  names[#names+1] = "Rotary 3"
  names[#names+1] = "Rotary 4"
  names[#names+1] = "Button 1"
  names[#names+1] = "Button 2"
  names[#names+1] = "Button 3"
  names[#names+1] = "Button 4"
  names[#names+1] = "To Insert FX Peak Meter"
  names[#names+1] = "From Insert FX Peak Meter"
  names[#names+1] = "Threshold"
  names[#names+1] = "Ratio"
  names[#names+1] = "Attack"
  names[#names+1] = "Release"
  names[#names+1] = "Make-Up Gain"
  names[#names+1] = "Compressor On"
  names[#names+1] = "Key On"
  names[#names+1] = "Gain Reduction"
  for f=1,8 do
    names[#names+1] = "FX"..f.." Send Level Meter"
    names[#names+1] = "FX"..f.." Send Level"
    names[#names+1] = "FX"..f.." Return Level Meter"
    names[#names+1] = "FX"..f.." Return Level"
    names[#names+1] = "FX"..f.." Pan"
    names[#names+1] = "FX"..f.." Mute"
  end
  names[#names+1] = "Dim -20dB"
  names[#names+1] = "Master Level Meter Left"
  names[#names+1] = "Master Level Meter Right"
  names[#names+1] = "Master Level Left Peak"
  names[#names+1] = "Master Level Right Peak"
  names[#names+1] = "Clip Indicator Left"
  names[#names+1] = "Clip Indicator Right"
  names[#names+1] = "Ctrl Room Source"
  names[#names+1] = "Ctrl Room FX Select"
  names[#names+1] = "Ctrl Room Level"
  names[#names+1] = "Bypass Insert FX"
  names[#names+1] = "Master Level"
  names[#names+1] = "Inserts Connected"
  names[#names+1] = "All Mutes Off"
  names[#names+1] = "All Solo Off"
  names[#names+1] = "Reset Clip"
  names[#names+1] = "Remote Base Channel"
  for c=1,64 do
    names[#names+1] = "Channel "..c.." Level"
    names[#names+1] = "Channel "..c.." Pan"
    names[#names+1] = "Channel "..c.." Width"
    names[#names+1] = "Channel "..c.." Mute"
    names[#names+1] = "Channel "..c.." Solo"
    names[#names+1] = "Channel "..c.." Input Gain"
    names[#names+1] = "Channel "..c.." Invert Phase"
    names[#names+1] = "Channel "..c.." Insert Pre"
    names[#names+1] = "Channel "..c.." Dyn Post EQ"
    names[#names+1] = "Channel "..c.." LPF Frequency"
    names[#names+1] = "Channel "..c.." LPF On"
    names[#names+1] = "Channel "..c.." HPF Frequency"
    names[#names+1] = "Channel "..c.." HPF On"
    names[#names+1] = "Channel "..c.." Filters Dyn S/C"
    names[#names+1] = "Channel "..c.." EQ On"
    names[#names+1] = "Channel "..c.." EQ E Mode"
    names[#names+1] = "Channel "..c.." HF Frequency"
    names[#names+1] = "Channel "..c.." HF Gain"
    names[#names+1] = "Channel "..c.." HF Bell"
    names[#names+1] = "Channel "..c.." HF On"
    names[#names+1] = "Channel "..c.." HMF Frequency"
    names[#names+1] = "Channel "..c.." HMF Gain"
    names[#names+1] = "Channel "..c.." HMF Q"
    names[#names+1] = "Channel "..c.." HMF On"
    names[#names+1] = "Channel "..c.." LMF Frequency"
    names[#names+1] = "Channel "..c.." LMF Gain"
    names[#names+1] = "Channel "..c.." LMF Q"
    names[#names+1] = "Channel "..c.." LMF On"
    names[#names+1] = "Channel "..c.." LF Frequency"
    names[#names+1] = "Channel "..c.." LF Gain"
    names[#names+1] = "Channel "..c.." LF Bell"
    names[#names+1] = "Channel "..c.." LF On"
    names[#names+1] = "Channel "..c.." Inserts Connected"
    names[#names+1] = "Channel "..c.." Bypass Insert FX"
    names[#names+1] = "Channel "..c.." Rotary 1"
    names[#names+1] = "Channel "..c.." Rotary 2"
    names[#names+1] = "Channel "..c.." Rotary 3"
    names[#names+1] = "Channel "..c.." Rotary 4"
    names[#names+1] = "Channel "..c.." Button 1"
    names[#names+1] = "Channel "..c.." Button 2"
    names[#names+1] = "Channel "..c.." Button 3"
    names[#names+1] = "Channel "..c.." Button 4"
    names[#names+1] = "Channel "..c.." To Insert FX Peak Meter"
    names[#names+1] = "Channel "..c.." From Insert FX Peak Meter"
    names[#names+1] = "Channel "..c.." Comp On"
    names[#names+1] = "Channel "..c.." C Threshold"
    names[#names+1] = "Channel "..c.." C Release"
    names[#names+1] = "Channel "..c.." C Ratio"
    names[#names+1] = "Channel "..c.." C Peak"
    names[#names+1] = "Channel "..c.." C Fast Atk"
    names[#names+1] = "Channel "..c.." Comp Gain Reduction"
    names[#names+1] = "Channel "..c.." Gate On"
    names[#names+1] = "Channel "..c.." G Threshold"
    names[#names+1] = "Channel "..c.." G Hold"
    names[#names+1] = "Channel "..c.." G Release"
    names[#names+1] = "Channel "..c.." G Range"
    names[#names+1] = "Channel "..c.." G Fast Atk"
    names[#names+1] = "Channel "..c.." Expander"
    names[#names+1] = "Channel "..c.." Gate Gain Reduction"
    names[#names+1] = "Channel "..c.." Key On"
    for f=1,8 do
      names[#names+1] = "Channel "..c.." FX"..f.." Send On"
      names[#names+1] = "Channel "..c.." FX"..f.." Send Level"
      names[#names+1] = "Channel "..c.." FX"..f.." Pre Fader"
    end
    names[#names+1] = "Channel "..c.." VU Meter"
    names[#names+1] = "Channel "..c.." VU Meter L"
    names[#names+1] = "Channel "..c.." VU Meter R"
  end

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=1} -- inserts pre
  data[#data+1] = {min=0, max=127} -- rotary 1 - 4
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1} -- button 1 - 4
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20} -- to/from insert fx peak meter
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=127} -- threshold
  data[#data+1] = {min=0, max=2} -- ratio
  data[#data+1] = {min=0, max=5} -- attack
  data[#data+1] = {min=0, max=4} -- release
  data[#data+1] = {min=0, max=127} -- make-up gain
  data[#data+1] = {min=0, max=1} -- compressor on
  data[#data+1] = {min=0, max=1} -- key on
  data[#data+1] = {min=0, max=20} -- gain reduction
  for f=1,8 do
    data[#data+1] = {min=0, max=20} -- fx 'f' send level meter
    data[#data+1] = {min=0, max=127} -- fx 'f' send level
    data[#data+1] = {min=0, max=20} -- fx 'f' return level meter
    data[#data+1] = {min=0, max=127} -- fx 'f' return level
    data[#data+1] = {min=-100, max=100} -- fx 'f' pan
    data[#data+1] = {min=0, max=1} -- fx 'f' mute
  end
  data[#data+1] = {min=0, max=1} -- dim -20db
  data[#data+1] = {min=0, max=32} -- master level meter left
  data[#data+1] = {min=0, max=32} -- master level meter right
  data[#data+1] = {min=0, max=32} -- master level left peak
  data[#data+1] = {min=0, max=32} -- master level right peak
  data[#data+1] = {min=0, max=1} -- clip indicator left
  data[#data+1] = {min=0, max=1} -- clip indicator right
  data[#data+1] = {min=0, max=2} -- ctrl room source
  data[#data+1] = {min=0, max=7} -- ctrl room fx select
  data[#data+1] = {min=0, max=127} -- ctrl room level
  data[#data+1] = {min=0, max=1} -- bypass insert fx
  data[#data+1] = {min=0, max=1000} -- master level
  data[#data+1] = {min=0, max=1} -- inserts connected
  data[#data+1] = {min=0, max=1} -- all mutes off
  data[#data+1] = {min=0, max=1} -- all solo off
  data[#data+1] = {min=0, max=1} -- reset clip
  data[#data+1] = {min=1, max=128} -- remote base channel
  for c=1,64 do
    data[#data+1] = {min=0, max=1000} -- channel 'c' level
    data[#data+1] = {min=-100, max=100} -- channel 'c' pan
    data[#data+1] = {min=0, max=127} -- channel 'c' width
    data[#data+1] = {min=0, max=1} -- channel 'c' mute
    data[#data+1] = {min=0, max=1} -- channel 'c' solo
    data[#data+1] = {min=-64, max=63} -- channel 'c' input gain
    data[#data+1] = {min=0, max=1} -- channel 'c' invert phase
    data[#data+1] = {min=0, max=1} -- channel 'c' insert pre
    data[#data+1] = {min=0, max=1} -- channel 'c' dyn post eq
    data[#data+1] = {min=0, max=1000} -- channel 'c' lpf frequency
    data[#data+1] = {min=0, max=1} -- channel 'c' lpf on
    data[#data+1] = {min=0, max=1000} -- channel 'c' hpf frequency
    data[#data+1] = {min=0, max=1} -- channel 'c' hpf on
    data[#data+1] = {min=0, max=1} -- channel 'c' filters dyn s/c
    data[#data+1] = {min=0, max=1} -- channel 'c' eq on
    data[#data+1] = {min=0, max=1} -- channel 'c' eq e mode
    data[#data+1] = {min=0, max=1000} -- channel 'c' hf frequency
    data[#data+1] = {min=-64, max=63} -- channel 'c' hf gain
    data[#data+1] = {min=0, max=1} -- channel 'c' hf bell
    data[#data+1] = {min=0, max=1} -- channel 'c' hf on
    data[#data+1] = {min=0, max=1000} -- channel 'c' hmf frequency
    data[#data+1] = {min=-64, max=63} -- channel 'c' hmf gain
    data[#data+1] = {min=0, max=127} -- channel 'c' hmf q
    data[#data+1] = {min=0, max=1} -- channel 'c' hmf on
    data[#data+1] = {min=0, max=1000} -- channel 'c' lmf frequency
    data[#data+1] = {min=-64, max=63} -- channel 'c' lmf gain
    data[#data+1] = {min=0, max=127} -- channel 'c' lmf q
    data[#data+1] = {min=0, max=1} -- channel 'c' lmf on
    data[#data+1] = {min=0, max=1000} -- channel 'c' lf frequency
    data[#data+1] = {min=-64, max=63} -- channel 'c' lf gain
    data[#data+1] = {min=0, max=1} -- channel 'c' lf bell
    data[#data+1] = {min=0, max=1} -- channel 'c' lf on
    data[#data+1] = {min=0, max=1} -- channel 'c' inserts connected
    data[#data+1] = {min=0, max=1} -- channel 'c' bypass insert fx
    data[#data+1] = {min=0, max=127} -- channel 'c' rotary 1 - 4
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=1} -- channel 'c' button 1 - 4
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=20} -- channel 'c' to/from insert fx peak meter
    data[#data+1] = {min=0, max=20}
    data[#data+1] = {min=0, max=1} -- channel 'c' comp on
    data[#data+1] = {min=0, max=127} -- channel 'c' c threshold
    data[#data+1] = {min=0, max=127} -- channel 'c' c release
    data[#data+1] = {min=0, max=127} -- channel 'c' c ratio
    data[#data+1] = {min=0, max=1} -- channel 'c' c peak
    data[#data+1] = {min=0, max=1} -- channel 'c' fast atk
    data[#data+1] = {min=0, max=5} -- channel 'c' comp gain reduction
    data[#data+1] = {min=0, max=1} -- channel 'c' gate on
    data[#data+1] = {min=0, max=127} -- channel 'c' g threshold
    data[#data+1] = {min=0, max=127} -- channel 'c' g hold
    data[#data+1] = {min=0, max=127} -- channel 'c' g release
    data[#data+1] = {min=0, max=127} -- channel 'c' g range
    data[#data+1] = {min=0, max=1} -- channel 'c' g fast atk
    data[#data+1] = {min=0, max=1} -- channel 'c' expander
    data[#data+1] = {min=0, max=5} -- channel 'c' gate gain reduction
    data[#data+1] = {min=0, max=1} -- channel 'c' key on
    for f=1,8 do
      data[#data+1] = {min=0, max=1} -- channel 'c' fx 'f' send on
      data[#data+1] = {min=0, max=127} -- channel 'c' fx 'f' send level
      data[#data+1] = {min=0, max=1} -- channel 'c' fx 'f' pre fader
    end
    data[#data+1] = {min=0, max=32} -- channel 'c' vu meter
    data[#data+1] = {min=0, max=32} -- channel 'c' vu meter l
    data[#data+1] = {min=0, max=32} -- channel 'c' vu meter r
  end

-- if we want this device type to have its own output count
  if (_G["Master_section_outputs"]~=nil) and (_G["Master_section_outputs"]>=1) then
-- assign it here
    out_count = _G["Master_section_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_kong_drum_designer"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "Master Level"
  names[#names+1] = "Note On Indicator"
  names[#names+1] = "Master FX P1"
  names[#names+1] = "Master FX P2"
  names[#names+1] = "Master FX On"
  names[#names+1] = "Bus FX P1"
  names[#names+1] = "Bus FX P2"
  names[#names+1] = "Bus FX On"
  names[#names+1] = "Level Bus FX to Master FX"
  names[#names+1] = "Master Level Output Left"
  names[#names+1] = "Master Level Output Right"
  names[#names+1] = "Master FX Peak Meter"
  names[#names+1] = "Bus FX Peak Meter"
  names[#names+1] = "Sample Loading Progress"
  for d=1,16 do
    names[#names+1] = "Drum "..d.." Level"
    names[#names+1] = "Drum "..d.." Pan"
    names[#names+1] = "Drum "..d.." Tone"
    names[#names+1] = "Drum "..d.." Bus FX Send"
    names[#names+1] = "Drum "..d.." Aux 1 Send"
    names[#names+1] = "Drum "..d.." Aux 2 Send"
    names[#names+1] = "Drum "..d.." Pitch Offset"
    names[#names+1] = "Drum "..d.." Decay Offset"
    names[#names+1] = "Drum "..d.." Output"
    names[#names+1] = "Drum "..d.." DM On"
    names[#names+1] = "Drum "..d.." FX1 On"
    names[#names+1] = "Drum "..d.." FX2 On"
    names[#names+1] = "Drum "..d.." DM Level"
    names[#names+1] = "Drum "..d.." DM Pitch"
    names[#names+1] = "Drum "..d.." DM Decay"
    names[#names+1] = "Drum "..d.." DM Variable"
    for f=1,2 do
      for p=1,2 do
        table.insert(names, "Drum "..d.." FX"..f.." P"..p)
      end
    end
    for f=1,2 do
      for h=1,4 do
        table.insert(names, "Drum "..d.." FX"..f.." Enable Hit "..h)
      end
    end
    names[#names+1] = "Drum "..d.." Pitch Bend Range"
  end
  for p=1,16 do
    names[#names+1] = "Pad "..p.." Solo"
    names[#names+1] = "Pad "..p.." Mute"
    names[#names+1] = "Pad "..p.." Hit Indication"
    names[#names+1] = "Pad "..p.." Drum Assignment"
    names[#names+1] = "Pad "..p.." Hit Type"
    local grp={"A","B","C","D","E","F","G","H","I"}
    for g=1,9 do
      table.insert(names, "Pad "..p.." Group "..grp[g])
    end
  end
  names[#names+1] = "Quick Sample"
  names[#names+1] = "Set all Mutes and Solos to Off"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=-1, max=127}
  for d=1,16 do
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=-120, max=120}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=9}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    for f=1,2 do
      for p=1,2 do
        data[#data+1] = {min=0, max=127}
      end
    end
    for f=1,2 do
      for h=1,4 do
        data[#data+1] = {min=0, max=1}
      end
    end
    data[#data+1] = {min=0, max=12}
  end
  for p=1,16 do
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=15}
    data[#data+1] = {min=0, max=3}
    for g=1,9 do
      data[#data+1] = {min=0, max=1}
    end
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}

 -- if we want this device type to have its own output count
  if (_G["Kong_outputs"]~=nil) and (_G["Kong_outputs"]>=1) then
-- assign it here
    out_count = _G["Kong_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end
      Has_pitch_wheel = Warp_compatible()

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_redrum_drum_computer"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend" -- might do nothing
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "Master Level"
  names[#names+1] = "Channel 8 and 9 Exclusive"
  names[#names+1] = "High Quality Interpolation"
  names[#names+1] = "Enable Pattern Section Playback"
  names[#names+1] = "Pattern Enable"
  names[#names+1] = "Selected Pattern"
  names[#names+1] = "Pattern Select in Bank"
  names[#names+1] = "Bank Select"
  for p=1,8 do
    table.insert(names, "Pattern "..p)
  end
  local bnk={"A","B","C","D"}
  for b=1,4 do
    table.insert(names, "Bank "..bnk[b])
  end
  names[#names+1] = "Run"
  names[#names+1] = "Resolution"
  names[#names+1] = "Shuffle"
  names[#names+1] = "Steps"
  names[#names+1] = "Edit Steps"
  names[#names+1] = "Step Playing"
  names[#names+1] = "Edit Accent"
  names[#names+1] = "Edit Flam"
  names[#names+1] = "Flam Amount"
  names[#names+1] = "Sample Loading Progress"
  for c=1,10 do
    names[#names+1] = "Channel "..c.." Play"
  end
  for c=1,10 do
    names[#names+1] = "Channel "..c.." Sample"
  end
  names[#names+1] = "Selected Drum"
  for d=1,10 do
    table.insert(names, "Select Drum "..d)
  end
  names[#names+1] = "Playing Step"
  for s=1,16 do
    names[#names+1] = "Step "..s.." Playing"
  end
  for s=1,16 do
    table.insert(names, "Selected Drum Toggle Step "..s)
  end
  for s=1,16 do
    table.insert(names, "Selected Drum Step "..s)
  end
  for s=1,16 do
    table.insert(names, "Selected Drum Step Out "..s)
  end
  for d=1,10 do
    names[#names+1] = "Drum "..d.." Mute"
    names[#names+1] = "Drum "..d.." Solo"
    names[#names+1] = "Drum "..d.." is Playing"
    for s=1,2 do
      names[#names+1] = "Drum "..d.." Send "..s.." Amount"
    end
    names[#names+1] = "Drum "..d.." Pan"
    names[#names+1] = "Drum "..d.." Level"
    names[#names+1] = "Drum "..d.." Vel to Level"
    names[#names+1] = "Drum "..d.." Length"
    names[#names+1] = "Drum "..d.." Decay/Gate Mode"
    names[#names+1] = "Drum "..d.." Pitch"
    if (d>5 and d<=7) then
      names[#names+1] = "Drum "..d.." Pitch Bend Amount"
      names[#names+1] = "Drum "..d.." Vel to Pitch Bend"
      names[#names+1] = "Drum "..d.." Pitch Bend Rate"
    elseif (d>0 and d<=2) or (d==10) then
      names[#names+1] = "Drum "..d.." Tone"
      names[#names+1] = "Drum "..d.." Vel to Tone"
    elseif (d>2 and d<=9) then
      if (d~=7) then
        names[#names+1] = "Drum "..d.." Sample Start"
        names[#names+1] = "Drum "..d.." Vel to Sample Start"
      end
    end
    for s=1,16 do
      table.insert(names, "Drum "..d.." Toggle Step "..s)
    end
    for s=1,16 do
      table.insert(names, "Drum "..d.." Step "..s)
    end
    for s=1,16 do
      table.insert(names, "Drum "..d.." Step Out "..s)
    end
  end
  names[#names+1] = "Remote Start Step"
  names[#names+1] = "Previous Remote Start Step"
  names[#names+1] = "Next Remote Start Step"
  names[#names+1] = "Previous 4 Remote Start Step"
  names[#names+1] = "Next 4 Remote Start Step"
  names[#names+1] = "Previous 8 Remote Start Step"
  names[#names+1] = "Next 8 Remote Start Step"
  names[#names+1] = "Previous 16 Remote Start Step"
  names[#names+1] = "Next 16 Remote Start Step"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-1, max=31}
  data[#data+1] = {min=0, max=7}
  data[#data+1] = {min=0, max=3}
  for p=1,8 do
    data[#data+1] = {min=0, max=1}
  end
  for b=1,4 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=8}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=1, max=64}
  data[#data+1] = {min=0, max=3}
  data[#data+1] = {min=0, max=63}
  data[#data+1] = {min=1, max=3}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-1, max=127}
  for c=1,10 do
    data[#data+1] = {min=0, max=1}
  end
  for c=1,10 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=1, max=10}
  for d=1,10 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=1, max=64}
  for s=1,16 do
    data[#data+1] = {min=0, max=1}
  end
  for s=1,16 do
    data[#data+1] = {min=0, max=1}
  end
  for s=1,16 do
    data[#data+1] = {min=0, max=3}
  end
  for s=1,16 do
    data[#data+1] = {min=0, max=4}
  end
  for d=1,10 do
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    for s=1,2 do
      data[#data+1] = {min=0, max=127}
    end
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=-64, max=63}
    if (d>5) and (d<=7) then
      data[#data+1] = {min=-64, max=63}
      data[#data+1] = {min=-64, max=63}
      data[#data+1] = {min=0, max=127}
    elseif (d>0) and (d<=2) or (d==10) then
      data[#data+1] = {min=-64, max=63}
      data[#data+1] = {min=-64, max=63}
    elseif (d>2) and (d<=9) then
      if (d~=7) then
        data[#data+1] = {min=0, max=127}
        data[#data+1] = {min=-64, max=63}
      end
    end
    for s=1,16 do
      data[#data+1] = {min=0, max=1}
    end
    for s=1,16 do
      data[#data+1] = {min=0, max=3}
    end
    for s=1,16 do
      data[#data+1] = {min=0, max=4}
    end
  end
  data[#data+1] = {min=1, max=64}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}

 -- if we want this device type to have its own output count
  if (_G["Redrum_outputs"]~=nil) and (_G["Redrum_outputs"]>=1) then
-- assign it here
    out_count = _G["Redrum_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end
      Has_pitch_wheel = Warp_compatible()

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_thor_polysonic_synthesizer"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "Pitch Bend Range"
  names[#names+1] = "Polyphony"
  names[#names+1] = "Release Polyphony"
  names[#names+1] = "Key Mode"
  names[#names+1] = "Portamento"
  names[#names+1] = "Portamento Mode"
  names[#names+1] = "Note On Indicator"
  names[#names+1] = "Note Trigger MIDI"
  names[#names+1] = "Note Trigger Step Seq"
  for r=1,2 do
    table.insert(names, "Rotary "..r)
  end
  for b=1,2 do
    table.insert(names, "Button "..b)
    names[#names+1] = "Button "..b.." MIDI Key"
    names[#names+1] = "Button "..b.." MIDI Key On"
  end
  names[#names+1] = "Master Level"
  names[#names+1] = "Mute"
  for o=1,3 do
    names[#names+1] = "Osc "..o.." Type"
    names[#names+1] = "Osc "..o.." Oct"
    names[#names+1] = "Osc "..o.." Semi"
    names[#names+1] = "Osc "..o.." Tune"
    names[#names+1] = "Osc "..o.." Kbd"
    names[#names+1] = "Osc "..o.." Mod"
    names[#names+1] = "Osc "..o.." Param B"
    names[#names+1] = "Osc "..o.." Param C"
  end
  names[#names+1] = "Osc 1 AM From Osc 2"
  names[#names+1] = "Osc 2 Sync To Osc 1"
  names[#names+1] = "Osc 2 Sync BW"
  names[#names+1] = "Osc 3 Sync To Osc 1"
  names[#names+1] = "Osc 3 Sync BW"
  names[#names+1] = "Osc 1 And 2 Level"
  names[#names+1] = "Osc 1 And 2 Balance"
  names[#names+1] = "Osc 3 Level"
  for f=1,2 do
    for o=1,3 do
      names[#names+1] = "Osc "..o.." To Filter "..f.." Enable"
    end
  end
  for f=1,3 do
    names[#names+1] = "Filter "..f.." Type"
    if (f==3) then
      names[#names+1] = "Filter "..f.." Global Env Amount"
      names[#names+1] = "Filter "..f.." Global Env Invert"
    else
      names[#names+1] = "Filter "..f.." Env Amount"
      names[#names+1] = "Filter "..f.." Env Invert"
    end
    names[#names+1] = "Filter "..f.." Velocity"
    names[#names+1] = "Filter "..f.." Kbd"
    names[#names+1] = "Filter "..f.." Drive"
    names[#names+1] = "Filter "..f.." Self Osc"
    names[#names+1] = "Filter "..f.." Freq"
    names[#names+1] = "Filter "..f.." Res"
    names[#names+1] = "Filter "..f.." Param X"
    names[#names+1] = "Filter "..f.." Param Y"
  end
  names[#names+1] = "Shaper On"
  names[#names+1] = "Shaper Type"
  names[#names+1] = "Shaper Drive"
  names[#names+1] = "Shaper Output Dest"
  names[#names+1] = "Filter2ToAmplifier Enable"
  for l=1,2 do
    names[#names+1] = "LFO "..l.." Key Sync"
    names[#names+1] = "LFO "..l.." Tempo Sync"
    names[#names+1] = "LFO "..l.." Waveform"
    names[#names+1] = "LFO "..l.." Rate"
    names[#names+1] = "LFO "..l.." Delay"
    if (l==1) then
      names[#names+1] = "LFO "..l.." KbdFollow"
    end
  end
  names[#names+1] = "Mod Env Gate Trig On"
  names[#names+1] = "Mod Env Delay"
  names[#names+1] = "Mod Env Attack"
  names[#names+1] = "Mod Env Decay"
  names[#names+1] = "Mod Env Release"
  names[#names+1] = "Mod Env Tempo Sync"
  names[#names+1] = "Mod Env Loop"
  names[#names+1] = "Filter Env Gate Trig On"
  names[#names+1] = "Filter Env Attack"
  names[#names+1] = "Filter Env Decay"
  names[#names+1] = "Filter Env Sustain"
  names[#names+1] = "Filter Env Release"
  names[#names+1] = "Amp Env Gate Trig On"
  names[#names+1] = "Amp Env Attack"
  names[#names+1] = "Amp Env Decay"
  names[#names+1] = "Amp Env Sustain"
  names[#names+1] = "Amp Env Release"
  names[#names+1] = "Amplifier Gain"
  names[#names+1] = "Amplifier Velocity"
  names[#names+1] = "Amplifier Pan"
  names[#names+1] = "Global Env Gate Trig On"
  names[#names+1] = "Global Env Delay"
  names[#names+1] = "Global Env Attack"
  names[#names+1] = "Global Env Hold"
  names[#names+1] = "Global Env Decay"
  names[#names+1] = "Global Env Sustain"
  names[#names+1] = "Global Env Release"
  names[#names+1] = "Global Env Tempo Sync"
  names[#names+1] = "Global Env Loop"
  names[#names+1] = "Chorus On"
  names[#names+1] = "Chorus Rate"
  names[#names+1] = "Chorus Amt"
  names[#names+1] = "Chorus Delay"
  names[#names+1] = "Chorus Feedback"
  names[#names+1] = "Chorus Dry Wet"
  names[#names+1] = "Delay On"
  names[#names+1] = "Delay Rate"
  names[#names+1] = "Delay Amt"
  names[#names+1] = "Delay Time"
  names[#names+1] = "Delay Feedback"
  names[#names+1] = "Delay Sync"
  names[#names+1] = "Delay Dry Wet"
  for m=1,13 do
    names[#names+1] = "Mod "..m.." Dest Amount"
    if (m>7 and m<=11) then
      names[#names+1] = "Mod "..m.." Dest 2 Amount"
    end
    names[#names+1] = "Mod "..m.." Scale Amount"
    if (m>11) then
      names[#names+1] = "Mod "..m.." Scale 2 Amount"
    end
  end
  names[#names+1] = "Step Sequencer Run Mode"
  names[#names+1] = "Step Sequencer Synced"
  names[#names+1] = "Step Sequencer Direction"
  names[#names+1] = "Step Sequencer Step Count"
  names[#names+1] = "Step Sequencer Step Index"
  names[#names+1] = "Step Sequencer Run"
  names[#names+1] = "Step Sequencer Rate"
  names[#names+1] = "Step Sequencer Edit Mode"
  names[#names+1] = "Step Sequencer Octave Range"
  names[#names+1] = "Pattern Step Value"
  for l=1,16 do
    table.insert(names, "Pattern Step LED "..l)
  end
  for k=1,16 do
    table.insert(names, "Pattern Step Knob "..k)
  end
  for g=1,16 do
    table.insert(names, "Pattern Step Gate "..g)
  end
  for n=1,16 do
    table.insert(names, "Pattern Step Note "..n)
  end
  for v=1,16 do
    table.insert(names, "Pattern Step Vel "..v)
  end
  for g=1,16 do
    table.insert(names, "Pattern Step Gate Length "..g)
  end
  for d=1,16 do
    table.insert(names, "Pattern Step Duration "..d)
  end
  for c=1,16 do
    table.insert(names, "Pattern Step Curve 1 "..c)
  end
  for c=1,16 do
    table.insert(names, "Pattern Step Curve 2 "..c)
  end

  in_count = #names
  _G["G_names"] = names

 -- DATA
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=24}
  data[#data+1] = {min=0, max=32}
  data[#data+1] = {min=0, max=32}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  for r=1,2 do
    data[#data+1] = {min=0, max=127}
  end
  for b=1,2 do
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=128}
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  for o=1,3 do
    data[#data+1] = {min=0, max=6}
    data[#data+1] = {min=0, max=9}
    data[#data+1] = {min=0, max=12}
    data[#data+1] = {min=-50, max=50}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=16383}
    data[#data+1] = {min=0, max=16383}
  end
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  for f=1,2 do
    for o=1,3 do
      data[#data+1] = {min=0, max=1}
    end
  end
  for f=1,3 do
    data[#data+1] = {min=0, max=4}
    if (f==3) then
      data[#data+1] = {min=0, max=127}
      data[#data+1] = {min=0, max=1}
    else
      data[#data+1] = {min=0, max=127}
      data[#data+1] = {min=0, max=1}
    end
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=16383}
    data[#data+1] = {min=0, max=16383}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=8}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  for l=1,2 do
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=17}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    if (l==1) then
      data[#data+1] = {min=0, max=127}
    end
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  for m=1,13 do
    data[#data+1] = {min=-100, max=100}
    if (m>7) and (m<=11) then
      data[#data+1] = {min=-100, max=100}
    end
    data[#data+1] = {min=-100, max=100}
    if (m>11) then
      data[#data+1] = {min=-100, max=100}
    end
  end
  data[#data+1] = {min=0, max=3}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=1, max=16}
  data[#data+1] = {min=0, max=15}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=5}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=16383}
  for l=1,16 do
    data[#data+1] = {min=0, max=1}
  end
  for k=1,16 do
    data[#data+1] = {min=0, max=16383}
  end
  for g=1,16 do
    data[#data+1] = {min=0, max=1}
  end
  for n=1,16 do
    data[#data+1] = {min=0, max=16383}
  end
  for v=1,16 do
    data[#data+1] = {min=0, max=127}
  end
  for g=1,16 do
    data[#data+1] = {min=0, max=100}
  end
  for d=1,16 do
    data[#data+1] = {min=0, max=16}
  end
  for c=1,16 do
    data[#data+1] = {min=0, max=127}
  end
  for c=1,16 do
    data[#data+1] = {min=0, max=127}
  end

 -- if we want this device type to have its own output count
  if (_G["Thor_outputs"]~=nil) and (_G["Thor_outputs"]>=1) then
-- assign it here
    out_count = _G["Thor_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

-- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end
      Has_pitch_wheel = Warp_compatible()

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_subtractor_analog_synthesizer"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "Amp Env Attack"
  names[#names+1] = "Amp Env Decay"
  names[#names+1] = "Amp Env Sustain"
  names[#names+1] = "Amp Env Release"
  names[#names+1] = "Master Level"
  names[#names+1] = "Mod Env Attack"
  names[#names+1] = "Mod Env Decay"
  names[#names+1] = "Mod Env Sustain"
  names[#names+1] = "Mod Env Release"
  names[#names+1] = "Mod Env Gain"
  names[#names+1] = "Mod Env Dest"
  names[#names+1] = "Mod Env Invert"
  names[#names+1] = "Filter Env Attack"
  names[#names+1] = "Filter Env Decay"
  names[#names+1] = "Filter Env Sustain"
  names[#names+1] = "Filter Env Release"
  names[#names+1] = "Filter Env Amount"
  names[#names+1] = "Filter Env Invert"
  names[#names+1] = "Filter Freq"
  names[#names+1] = "Filter Res"
  names[#names+1] = "Filter Kbd Track"
  names[#names+1] = "Filter Type"
  names[#names+1] = "Filter Link Freq On/Off"
  names[#names+1] = "Filter2 On/Off"
  names[#names+1] = "Filter2 Freq"
  names[#names+1] = "Filter2 Res"
  names[#names+1] = "Osc1 Wave"
  names[#names+1] = "Osc1 Octave"
  names[#names+1] = "Osc1 Semitone"
  names[#names+1] = "Osc1 Fine Tune"
  names[#names+1] = "Osc1 Phase Mode"
  names[#names+1] = "Osc1 Phase Diff"
  names[#names+1] = "Osc1 Kbd Track"
  names[#names+1] = "Osc2 On/Off"
  names[#names+1] = "Osc2 Wave"
  names[#names+1] = "Osc2 Octave"
  names[#names+1] = "Osc2 Semitone"
  names[#names+1] = "Osc2 Fine Tune"
  names[#names+1] = "Osc2 Phase Mode"
  names[#names+1] = "Osc2 Phase Diff"
  names[#names+1] = "Osc2 Kbd Track"
  names[#names+1] = "Osc Mix"
  names[#names+1] = "FM Amount"
  names[#names+1] = "Ring Mod"
  names[#names+1] = "LFO1 Rate"
  names[#names+1] = "LFO1 Amount"
  names[#names+1] = "LFO1 Wave"
  names[#names+1] = "LFO1 Dest"
  names[#names+1] = "LFO2 Rate"
  names[#names+1] = "LFO2 Amount"
  names[#names+1] = "LFO2 Delay"
  names[#names+1] = "LFO2 Dest"
  names[#names+1] = "LFO2 Kbd Track"
  names[#names+1] = "Portamento"
  names[#names+1] = "Polyphony"
  names[#names+1] = "Key Mode"
  names[#names+1] = "Low Bandwidth On/Off"
  names[#names+1] = "Filter Freq Mod Wheel Amount"
  names[#names+1] = "Filter Res Mod Wheel Amount"
  names[#names+1] = "FM Mod Wheel Amount"
  names[#names+1] = "Phase Diff Mod Wheel Amount"
  names[#names+1] = "LFO1 Mod Wheel Amount"
  names[#names+1] = "Pitch Bend Range"
  names[#names+1] = "Filter Freq Ext Mod"
  names[#names+1] = "LFO1 Ext Mod"
  names[#names+1] = "Amp Ext Mod"
  names[#names+1] = "FM Ext Mod"
  names[#names+1] = "Ext Mod Select"
  names[#names+1] = "Noise On/Off"
  names[#names+1] = "Noise Level"
  names[#names+1] = "Noise Decay"
  names[#names+1] = "Noise Color"
  names[#names+1] = "Amp Vel Amount"
  names[#names+1] = "FM Vel Amount"
  names[#names+1] = "Mod Env Vel Amount"
  names[#names+1] = "Phase Vel Amount"
  names[#names+1] = "Filter2 Freq Vel Amount"
  names[#names+1] = "Filter Env Vel Amount"
  names[#names+1] = "Filter Decay Vel Amount"
  names[#names+1] = "Mix Vel Amount"
  names[#names+1] = "Amp Attack Vel Amount"
  names[#names+1] = "LFO Sync Enable"
  names[#names+1] = "Note On Indicator"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127} -- keyboard
  data[#data+1] = {min=0, max=16383} -- pitch bend
  data[#data+1] = {min=0, max=127} -- mod wheel
  data[#data+1] = {min=0, max=127} -- channel pressure
  data[#data+1] = {min=0, max=127} -- expression
  data[#data+1] = {min=0, max=127} -- damper pedal
  data[#data+1] = {min=0, max=127} -- breath
  data[#data+1] = {min=0, max=127} -- amp env attack
  data[#data+1] = {min=0, max=127} -- amp env decay
  data[#data+1] = {min=0, max=127} -- amp env sustain
  data[#data+1] = {min=0, max=127} -- amp env release
  data[#data+1] = {min=0, max=127} -- master level
  data[#data+1] = {min=0, max=127} -- mod env attack
  data[#data+1] = {min=0, max=127} -- mod env decay
  data[#data+1] = {min=0, max=127} -- mod env sustain
  data[#data+1] = {min=0, max=127} -- mod env release
  data[#data+1] = {min=0, max=127} -- mod env gain
  data[#data+1] = {min=0, max=5} -- mod env dest
  data[#data+1] = {min=0, max=1} -- mod env invert
  data[#data+1] = {min=0, max=127} -- filter env attack
  data[#data+1] = {min=0, max=127} -- filter env decay
  data[#data+1] = {min=0, max=127} -- filter env sustain
  data[#data+1] = {min=0, max=127} -- filter env release
  data[#data+1] = {min=0, max=127} -- filter env amount
  data[#data+1] = {min=0, max=1} -- filter env invert
  data[#data+1] = {min=0, max=127} -- filter freq
  data[#data+1] = {min=0, max=127} -- filter res
  data[#data+1] = {min=0, max=127} -- filter kbd track
  data[#data+1] = {min=0, max=4} -- filter type
  data[#data+1] = {min=0, max=1} -- filter link freq on/off
  data[#data+1] = {min=0, max=1} -- filter 2 on/off
  data[#data+1] = {min=0, max=127} -- filter 2 freq
  data[#data+1] = {min=0, max=127} -- filter 2 res
  data[#data+1] = {min=0, max=31} -- osc 1 wave
  data[#data+1] = {min=0, max=9} -- osc 1 octave
  data[#data+1] = {min=0, max=12} -- osc 1 semitone
  data[#data+1] = {min=-50, max=50} -- osc 1 finetune
  data[#data+1] = {min=0, max=2} -- osc 1 phase mode
  data[#data+1] = {min=0, max=127} -- osc 1 phase diff
  data[#data+1] = {min=0, max=1} -- osc 1 kbd Track
  data[#data+1] = {min=0, max=1} -- osc 2 on/off
  data[#data+1] = {min=0, max=31} -- osc 2 wave
  data[#data+1] = {min=0, max=9} -- osc 2 octave
  data[#data+1] = {min=0, max=12} -- osc 2 semitone
  data[#data+1] = {min=-50, max=50} -- osc 2 finetune
  data[#data+1] = {min=0, max=2} -- osc 2 phase mode
  data[#data+1] = {min=0, max=127} -- osc 2 phase diff
  data[#data+1] = {min=0, max=1} -- osc 2 kbd track
  data[#data+1] = {min=0, max=127} -- osc mix
  data[#data+1] = {min=0, max=127} -- fm amount
  data[#data+1] = {min=0, max=1} -- ring mod
  data[#data+1] = {min=0, max=127} -- lfo 1 rate
  data[#data+1] = {min=0, max=127} -- lfo 1 amount
  data[#data+1] = {min=0, max=5} -- lfo 1 wave
  data[#data+1] = {min=0, max=5} -- lfo 1 dest
  data[#data+1] = {min=0, max=127} -- lfo 2 rate
  data[#data+1] = {min=0, max=127} -- lfo 2 amount
  data[#data+1] = {min=0, max=127} -- lfo 2 delay
  data[#data+1] = {min=0, max=3} -- lfo 2 dest
  data[#data+1] = {min=0, max=127} -- lfo 2 kbd track
  data[#data+1] = {min=0, max=127} -- portamento
  data[#data+1] = {min=1, max=99} -- polyphony
  data[#data+1] = {min=0, max=1} -- key mode
  data[#data+1] = {min=0, max=1} -- low bandwidth
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=24}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}

 -- if we want this device type to have its own output count
  if (_G["Subtractor_outputs"]~=nil) and (_G["Subtractor_outputs"]>=1) then
-- assign it here
    out_count = _G["Subtractor_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end
      Has_pitch_wheel = Warp_compatible()

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_malstrom_graintable_synthesizer"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  local ab={"A","B"}
  for m=1,2 do
    names[#names+1] = "Modulator "..ab[m].." On/Off"
    names[#names+1] = "Modulator "..ab[m].." Curve"
    names[#names+1] = "Modulator "..ab[m].." Rate"
    names[#names+1] = "Modulator "..ab[m].." One Shot"
    names[#names+1] = "Modulator "..ab[m].." Sync"
    names[#names+1] = "Modulator "..ab[m].." Target"
    if (m==2) then
      names[#names+1] = "Modulator "..ab[m].." To Level"
      names[#names+1] = "Modulator "..ab[m].." To Filter"
      names[#names+1] = "Modulator "..ab[m].." To Modulator A"
      names[#names+1] = "Modulator "..ab[m].." To Motion"
    elseif (m==1) then
      names[#names+1] = "Modulator "..ab[m].." To Pitch"
      names[#names+1] = "Modulator "..ab[m].." To Index"
      names[#names+1] = "Modulator "..ab[m].." To Shift"
    end
  end
  for o=1,2 do
    names[#names+1] = "Oscillator "..ab[o].." On/Off"
    names[#names+1] = "Oscillator "..ab[o].." Index"
    names[#names+1] = "Oscillator "..ab[o].." Motion"
    names[#names+1] = "Oscillator "..ab[o].." Octave"
    names[#names+1] = "Oscillator "..ab[o].." Semi"
    names[#names+1] = "Oscillator "..ab[o].." Cent"
    names[#names+1] = "Oscillator "..ab[o].." Shift"
    names[#names+1] = "Oscillator "..ab[o].." Attack"
    names[#names+1] = "Oscillator "..ab[o].." Decay"
    names[#names+1] = "Oscillator "..ab[o].." Sustain"
    names[#names+1] = "Oscillator "..ab[o].." Release"
    names[#names+1] = "Oscillator "..ab[o].." Gain"
  end
  names[#names+1] = "Filter B On/Off"
  names[#names+1] = "Filter B Mode"
  names[#names+1] = "Filter B Freq"
  names[#names+1] = "Filter B Resonance"
  names[#names+1] = "Filter B Kbd Track"
  names[#names+1] = "Filter B Env"
  names[#names+1] = "Filter Env Attack"
  names[#names+1] = "Filter Env Decay"
  names[#names+1] = "Filter Env Sustain"
  names[#names+1] = "Filter Env Release"
  names[#names+1] = "Filter Env Amount"
  names[#names+1] = "Filter Env Invert"
  names[#names+1] = "Filter A On/Off"
  names[#names+1] = "Filter A Mode"
  names[#names+1] = "Filter A Freq"
  names[#names+1] = "Filter A Resonance"
  names[#names+1] = "Filter A Kbd Track"
  names[#names+1] = "Filter A Env"
  names[#names+1] = "Shaper On/Off"
  names[#names+1] = "Shaper Mode"
  names[#names+1] = "Shaper Amount"
  names[#names+1] = "Velocity Target"
  names[#names+1] = "Velocity To Level A"
  names[#names+1] = "Velocity To Level B"
  names[#names+1] = "Velocity To Filter Env"
  names[#names+1] = "Velocity To Attack"
  names[#names+1] = "Velocity To Shift"
  names[#names+1] = "Velocity To Modulator"
  names[#names+1] = "Mod Wheel Target"
  names[#names+1] = "Mod Wheel To Index"
  names[#names+1] = "Mod Wheel To Shift"
  names[#names+1] = "Mod Wheel To Filter"
  names[#names+1] = "Mod Wheel To Modulator"
  names[#names+1] = "Route Oscillator B To Filter B"
  names[#names+1] = "Route Oscillator A To Filter B"
  names[#names+1] = "Route Oscillator A To Shaper"
  names[#names+1] = "Route Filter B To Shaper"
  names[#names+1] = "Polyphony"
  names[#names+1] = "Portamento"
  names[#names+1] = "Legato On/Off"
  names[#names+1] = "Pitch Bend Range"
  names[#names+1] = "Master Level"
  names[#names+1] = "Spread Amount"
  names[#names+1] = "Note On Indicator"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  for m=1,2 do
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=31}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=2}
    if (m==2) then
      data[#data+1] = {min=-64, max=63}
      data[#data+1] = {min=-64, max=63}
      data[#data+1] = {min=-64, max=63}
      data[#data+1] = {min=-64, max=63}
    elseif (m==1) then
      data[#data+1] = {min=-64, max=63}
      data[#data+1] = {min=-64, max=63}
      data[#data+1] = {min=-64, max=63}
    end
  end
  for o=1,2 do
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=8}
    data[#data+1] = {min=0, max=12}
    data[#data+1] = {min=-50, max=50}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=127}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=1, max=16}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=24}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Malstrom_outputs"]~=nil) and (_G["Malstrom_outputs"]>=1) then
-- assign it here
    out_count = _G["Malstrom_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end
      Has_pitch_wheel = Warp_compatible()

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_id8_instrument_device"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "Note On Indicator"
  names[#names+1] = "Parameter 1"
  names[#names+1] = "Parameter 2"
  names[#names+1] = "Volume"
  names[#names+1] = "Sample Loading Progress"
  names[#names+1] = "Category"
  names[#names+1] = "Sound"
  names[#names+1] = "Sound A"
  names[#names+1] = "Sound B"
  names[#names+1] = "Sound C"
  names[#names+1] = "Sound D"
  names[#names+1] = "Preset"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-1, max=127}
  data[#data+1] = {min=0, max=8}
  data[#data+1] = {min=0, max=3}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=35}

 -- if we want this device type to have its own output count
  if (_G["Id8_outputs"]~=nil) and (_G["Id8_outputs"]>=1) then
-- assign it here
    out_count = _G["Id8_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end
      Has_pitch_wheel = Warp_compatible()

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_dr_rex_loop_player"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "Amp Env Attack"
  names[#names+1] = "Amp Env Decay"
  names[#names+1] = "Amp Env Sustain"
  names[#names+1] = "Amp Env Release"
  names[#names+1] = "Master Level"
  names[#names+1] = "Filter Env Attack"
  names[#names+1] = "Filter Env Decay"
  names[#names+1] = "Filter Env Sustain"
  names[#names+1] = "Filter Env Release"
  names[#names+1] = "Filter Env Amount"
  names[#names+1] = "Filter On/Off"
  names[#names+1] = "Filter Freq"
  names[#names+1] = "Filter Res"
  names[#names+1] = "Filter Mode"
  names[#names+1] = "Osc Octave"
  names[#names+1] = "Transpose"
  names[#names+1] = "Osc Fine Tune"
  names[#names+1] = "Osc Env Amount"
  names[#names+1] = "LFO1 Rate"
  names[#names+1] = "LFO1 Amount"
  names[#names+1] = "LFO1 Wave"
  names[#names+1] = "LFO1 Dest"
  names[#names+1] = "Polyphony"
  names[#names+1] = "Low Bandwidth On/Off"
  names[#names+1] = "High Quality Interpolation"
  names[#names+1] = "Filter Freq Mod Wheel Amount"
  names[#names+1] = "Filter Res Mod Wheel Amount"
  names[#names+1] = "Filter Decay Mod Wheel Amount"
  names[#names+1] = "Amp Vel Amount"
  names[#names+1] = "Filter Env Vel Amount"
  names[#names+1] = "Filter Decay Vel Amount"
  names[#names+1] = "LFO Sync Enable"
  names[#names+1] = "Note On Indicator"
  names[#names+1] = "Sample Loading Progress"
  names[#names+1] = "Enable Loop Playback"
  names[#names+1] = "Selected Loop Slot"
  names[#names+1] = "Trigger Next Setting"
  names[#names+1] = "Selected Loop in Editor"
  names[#names+1] = "Follow Loop Playback"
  names[#names+1] = "Notes to Slot"
  names[#names+1] = "Select Previous Patch"
  names[#names+1] = "Select Next Patch"
  names[#names+1] = "Run"
  for l=1,8 do
    table.insert(names, "Select Loop "..l)
  end
  names[#names+1] = "Loop Level"
  names[#names+1] = "Loop Transpose"
  names[#names+1] = "Mute"
  names[#names+1] = "Pitch Bend Range"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=8}
  data[#data+1] = {min=-12, max=12}
  data[#data+1] = {min=-50, max=50}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=5}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=1, max=99}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-1, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-1, max=7}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=7}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=1, max=8}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  for l=1,8 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-12, max=12}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=24}

 -- if we want this device type to have its own output count
  if (_G["Dr_rex_outputs"]~=nil) and (_G["Dr_rex_outputs"]>=1) then
-- assign it here
    out_count = _G["Dr_rex_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end
      Has_pitch_wheel = Warp_compatible()

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_nn_xt_advanced_sampler"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "External Controller"
  names[#names+1] = "Note On Indicator"
  names[#names+1] = "External Controller Source"
  names[#names+1] = "High Quality Interpolation"
  names[#names+1] = "Filter Freq"
  names[#names+1] = "Filter Res"
  names[#names+1] = "Amp Env Attack"
  names[#names+1] = "Amp Env Decay"
  names[#names+1] = "Amp Env Release"
  names[#names+1] = "Mod Env Decay"
  names[#names+1] = "Master Volume"
  names[#names+1] = "Sample Loading Progress"
  names[#names+1] = "Sample"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-1, max=127}
  data[#data+1] = {min=0, max=1}

 -- if we want this device type to have its own output count
  if (_G["Nn-xt_outputs"]~=nil) and (_G["Nn-xt_outputs"]>=1) then
-- assign it here
    out_count = _G["Nn-xt_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end
      Has_pitch_wheel = Warp_compatible()

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_nn19_digital_sampler"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "Amp Env Attack"
  names[#names+1] = "Amp Env Decay"
  names[#names+1] = "Amp Env Sustain"
  names[#names+1] = "Amp Env Release"
  names[#names+1] = "Master Level"
  names[#names+1] = "Filter Env Attack"
  names[#names+1] = "Filter Env Decay"
  names[#names+1] = "Filter Env Sustain"
  names[#names+1] = "Filter Env Release"
  names[#names+1] = "Filter Env Amount"
  names[#names+1] = "Filter Env Invert"
  names[#names+1] = "Filter On/Off"
  names[#names+1] = "Filter Freq"
  names[#names+1] = "Filter Res"
  names[#names+1] = "Filter Kbd Track"
  names[#names+1] = "Filter Mode"
  names[#names+1] = "Sample Start"
  names[#names+1] = "Osc Octave"
  names[#names+1] = "Osc Semitone"
  names[#names+1] = "Osc Fine Tune"
  names[#names+1] = "Osc Kbd Track"
  names[#names+1] = "Osc Env Amount"
  names[#names+1] = "LFO Rate"
  names[#names+1] = "LFO Amount"
  names[#names+1] = "LFO Wave"
  names[#names+1] = "LFO Dest"
  names[#names+1] = "Key Mode"
  names[#names+1] = "Portamento"
  names[#names+1] = "Polyphony"
  names[#names+1] = "Stereo Spread"
  names[#names+1] = "Spread Mode"
  names[#names+1] = "Low Bandwidth On/Off"
  names[#names+1] = "High Quality Interpolation"
  names[#names+1] = "Filter Freq Mod Wheel Amount"
  names[#names+1] = "Filter Res Mod Wheel Amount"
  names[#names+1] = "Filter Decay Mod Wheel Amount"
  names[#names+1] = "Amp Mod Wheel Amount"
  names[#names+1] = "LFO Mod Wheel Amount"
  names[#names+1] = "Filter Freq Ext Mod"
  names[#names+1] = "LFO Ext Mod"
  names[#names+1] = "Amp Ext Mod"
  names[#names+1] = "Ext Mod Select"
  names[#names+1] = "Amp Vel Amount"
  names[#names+1] = "Amp Attack Vel Amount"
  names[#names+1] = "Filter Env Vel Amount"
  names[#names+1] = "Filter Decay Vel Amount"
  names[#names+1] = "Sample Start Vel Amount"
  names[#names+1] = "LFO Sync Enable"
  names[#names+1] = "Note On Indicator"
  names[#names+1] = "Sample Loading Progress"
  names[#names+1] = "Sample"
  names[#names+1] = "Solo Sample"
  names[#names+1] = "Pitch Bend Range"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=8}
  data[#data+1] = {min=0, max=12}
  data[#data+1] = {min=-50, max=50}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=5}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=1, max=99}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-1, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=24}

 -- if we want this device type to have its own output count
  if (_G["Nn19_outputs"]~=nil) and (_G["Nn19_outputs"]>=1) then
-- assign it here
    out_count = _G["Nn19_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end
      Has_pitch_wheel = Warp_compatible()

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_scream_4_distortion"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Damage On/Off"
  names[#names+1] = "Damage Control"
  names[#names+1] = "Damage Type"
  names[#names+1] = "Parameter 1"
  names[#names+1] = "Parameter 2"
  names[#names+1] = "Cut On/Off"
  names[#names+1] = "Cut Lo"
  names[#names+1] = "Cut Mid"
  names[#names+1] = "Cut Hi"
  names[#names+1] = "Body On/Off"
  names[#names+1] = "Body Resonance"
  names[#names+1] = "Body Scale"
  names[#names+1] = "Body Auto"
  names[#names+1] = "Body Type"
  names[#names+1] = "Master Level"
  names[#names+1] = "Input Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=9}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Scream_4_outputs"]~=nil) and (_G["Scream_4_outputs"]>=1) then
-- assign it here
    out_count = _G["Scream_4_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
    Has_pitch_wheel = Warp_compatible()
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end

_G["Define_bv512_digital_vocoder"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Band Count"
  names[#names+1] = "Vocoder/Equalizer"
  names[#names+1] = "HF Emphasis"
  names[#names+1] = "Shift"
  names[#names+1] = "Attack"
  names[#names+1] = "Decay"
  names[#names+1] = "Hold"
  names[#names+1] = "Dry/Wet"
  for b=1,32 do
    table.insert(names, "Band Level "..b)
  end
  for m=1,32 do
    table.insert(names, "Mod Level "..m)
  end
  names[#names+1] = "Source Peak Meter"
  names[#names+1] = "Modulator Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  for b=1,32 do
    data[#data+1] = {min=0, max=127}
  end
  for m=1,32 do
    data[#data+1] = {min=0, max=127}
  end
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Bv512_outputs"]~=nil) and (_G["Bv512_outputs"]>=1) then
-- assign it here
    out_count = _G["Bv512_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_rv7000_advanced_reverb"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Dry/Wet"
  names[#names+1] = "Decay"
  names[#names+1] = "HF Damp"
  names[#names+1] = "Hi EQ"
  names[#names+1] = "Gate On/Off"
  names[#names+1] = "EQ On/Off"
  names[#names+1] = "Edit Mode"
  for k=1,8 do
    table.insert(names, "Soft Knob "..k)
  end
  names[#names+1] = "Sample"
  names[#names+1] = "Input Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=2}
  for k=1,8 do
    data[#data+1] = {min=0, max=16383}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Rv7000_outputs"]~=nil) and (_G["Rv7000_outputs"]>=1) then
-- assign it here
    out_count = _G["Rv7000_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_neptune_pitch_adjuster"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "Enabled"
  names[#names+1] = "Pitch Bend Range"
  names[#names+1] = "Vibrato Rate"
  names[#names+1] = "Low Freq Input"
  names[#names+1] = "Wide Vibrato"
  names[#names+1] = "Live Mode"
  names[#names+1] = "MIDI Destination"
  names[#names+1] = "Pitch Adjust On/Off"
  names[#names+1] = "Pitch Adjust Amount"
  names[#names+1] = "Scale Memory"
  names[#names+1] = "Correction Speed"
  names[#names+1] = "Preserve Expression"
  names[#names+1] = "Transpose On/Off"
  names[#names+1] = "Semitones"
  names[#names+1] = "Cent"
  names[#names+1] = "Formant On/Off"
  names[#names+1] = "Formant Shift"
  names[#names+1] = "Pitched Signal Level"
  names[#names+1] = "Voice Synth Level"
  names[#names+1] = "Input Peak Meter"
  names[#names+1] = "MIDI Input"
  names[#names+1] = "Catch Zone"
  names[#names+1] = "Target Note"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=24}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-200, max=200}
  data[#data+1] = {min=0, max=3}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-12, max=12}
  data[#data+1] = {min=-50, max=50}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=20, max=600}
  data[#data+1] = {min=0, max=11}

 -- if we want this device type to have its own output count
  if (_G["Neptune_outputs"]~=nil) and (_G["Neptune_outputs"]>=1) then
-- assign it here
    out_count = _G["Neptune_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_mclass_equalizer"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Low Cut Enable"
  names[#names+1] = "Low Shelf Enable"
  names[#names+1] = "Low Shelf Gain"
  names[#names+1] = "Low Shelf Q"
  names[#names+1] = "Low Shelf Frequency"
  names[#names+1] = "Parametric 1 Enable"
  names[#names+1] = "Parametric 1 Gain"
  names[#names+1] = "Parametric 1 Q"
  names[#names+1] = "Parametric 1 Frequency"
  names[#names+1] = "Parametric 2 Enable"
  names[#names+1] = "Parametric 2 Gain"
  names[#names+1] = "Parametric 2 Q"
  names[#names+1] = "Parametric 2 Frequency"
  names[#names+1] = "Hi Shelf Enable"
  names[#names+1] = "Hi Shelf Gain"
  names[#names+1] = "Hi Shelf Q"
  names[#names+1] = "Hi Shelf Frequency"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Mclass_equalizer_outputs"]~=nil) and (_G["Mclass_equalizer_outputs"]>=1) then
-- assign it here
    out_count = _G["Mclass_equalizer_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_mclass_compressor"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Input Gain"
  names[#names+1] = "Threshold"
  names[#names+1] = "Soft Knee"
  names[#names+1] = "Ratio"
  names[#names+1] = "Sidechain Active"
  names[#names+1] = "Sidechain Solo"
  names[#names+1] = "Attack"
  names[#names+1] = "Release"
  names[#names+1] = "Adapt"
  names[#names+1] = "Output Gain"
  names[#names+1] = "Peak Meter"
  names[#names+1] = "Gain Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=11}

 -- if we want this device type to have its own output count
  if (_G["Mclass_compressor_outputs"]~=nil) and (_G["Mclass_compressor_outputs"]>=1) then
-- assign it here
    out_count = _G["Mclass_compressor_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_mclass_maximizer"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Input Gain"
  names[#names+1] = "Limiter Enable"
  names[#names+1] = "Look Ahead Enable"
  names[#names+1] = "Attack Speed"
  names[#names+1] = "Release Speed"
  names[#names+1] = "Output Gain"
  names[#names+1] = "Soft Clip Enable"
  names[#names+1] = "Soft Clip Amount"
  names[#names+1] = "Output Level Meter Mode"
  names[#names+1] = "Peak Meter"
  names[#names+1] = "Gain Meter"
  names[#names+1] = "Output Level Left"
  names[#names+1] = "Output Level Right"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=11}
  data[#data+1] = {min=0, max=25}
  data[#data+1] = {min=0, max=25}

 -- if we want this device type to have its own output count
  if (_G["Mclass_maximizer_outputs"]~=nil) and (_G["Mclass_maximizer_outputs"]>=1) then
-- assign it here
    out_count = _G["Mclass_maximizer_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_mclass_stereo_imager"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Low Width"
  names[#names+1] = "Low Band Active"
  names[#names+1] = "Low Width Meter"
  names[#names+1] = "High Width"
  names[#names+1] = "High Band Active"
  names[#names+1] = "High Width Meter"
  names[#names+1] = "X-Over Frequency"
  names[#names+1] = "Solo Mode"
  names[#names+1] = "Separate Out Mode"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=7}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=7}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Mclass_stereo_imager_outputs"]~=nil) and (_G["Mclass_stereo_imager_outputs"]>=1) then
-- assign it here
    out_count = _G["Mclass_stereo_imager_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_rv_7_digital_reverb"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Size"
  names[#names+1] = "Decay"
  names[#names+1] = "Damping"
  names[#names+1] = "Algorithm"
  names[#names+1] = "Dry/Wet"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=9}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Rv-7_outputs"]~=nil) and (_G["Rv-7_outputs"]>=1) then
-- assign it here
    out_count = _G["Rv-7_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_ddl_1_digital_delay_line"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Unit"
  names[#names+1] = "Step Length"
  names[#names+1] = "DelayTime (steps)"
  names[#names+1] = "DelayTime (ms)"
  names[#names+1] = "Feedback"
  names[#names+1] = "Pan"
  names[#names+1] = "Dry/Wet Balance"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=1, max=16}
  data[#data+1] = {min=1, max=2000}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Ddl-1_outputs"]~=nil) and (_G["Ddl-1_outputs"]>=1) then
-- assign it here
    out_count = _G["Ddl-1_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_d_11_foldback_distortion"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Amount"
  names[#names+1] = "Foldback"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["D-11_outputs"]~=nil) and (_G["D-11_outputs"]>=1) then
-- assign it here
    out_count = _G["D-11_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_ecf_42_envelope_controlled_filter"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Attack"
  names[#names+1] = "Decay"
  names[#names+1] = "Sustain"
  names[#names+1] = "Release"
  names[#names+1] = "Frequency"
  names[#names+1] = "Resonance"
  names[#names+1] = "Env Amount"
  names[#names+1] = "Mode"
  names[#names+1] = "Velocity"
  names[#names+1] = "Trigger"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Ecf-42_outputs"]~=nil) and (_G["Ecf-42_outputs"]>=1) then
-- assign it here
    out_count = _G["Ecf-42_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_cf_101_chorus_flanger"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Delay"
  names[#names+1] = "Feedback"
  names[#names+1] = "Rate"
  names[#names+1] = "Modulation Amount"
  names[#names+1] = "Send/Insert Mode"
  names[#names+1] = "LFO Sync Enable"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Cf-101_outputs"]~=nil) and (_G["Cf-101_outputs"]>=1) then
-- assign it here
    out_count = _G["Cf-101_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_ph_90_phaser"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Frequency"
  names[#names+1] = "Split"
  names[#names+1] = "Width"
  names[#names+1] = "Rate"
  names[#names+1] = "Frequency Modulation"
  names[#names+1] = "Feedback"
  names[#names+1] = "LFO Sync Enable"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Ph-90_outputs"]~=nil) and (_G["Ph-90_outputs"]>=1) then
-- assign it here
    out_count = _G["Ph-90_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_un_16_unison"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Voice Count"
  names[#names+1] = "Detune"
  names[#names+1] = "Dry/Wet"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Un-16_outputs"]~=nil) and (_G["Un-16_outputs"]>=1) then
-- assign it here
    out_count = _G["Un-16_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_comp_01_compressor_limiter"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Ratio"
  names[#names+1] = "Threshold"
  names[#names+1] = "Attack"
  names[#names+1] = "Release"
  names[#names+1] = "Gain"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Comp-01_outputs"]~=nil) and (_G["Comp-01_outputs"]>=1) then
-- assign it here
    out_count = _G["Comp-01_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_peq_2_two_band_parametric_eq"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Filter A Freq"
  names[#names+1] = "Filter A Q"
  names[#names+1] = "Filter A Gain"
  names[#names+1] = "Filter B On/Off"
  names[#names+1] = "Filter B Freq"
  names[#names+1] = "Filter B Q"
  names[#names+1] = "Filter B Gain"
  names[#names+1] = "Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Peq-2_outputs"]~=nil) and (_G["Peq-2_outputs"]>=1) then
-- assign it here
    out_count = _G["Peq-2_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_rpg_8_monophonic_arpeggiator"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend" -- might do nothing
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Arpeggiator Enable"
  names[#names+1] = "Mode"
  names[#names+1] = "Insert"
  names[#names+1] = "Insert Off"
  names[#names+1] = "Insert Low"
  names[#names+1] = "Insert High"
  names[#names+1] = "Insert 3-1"
  names[#names+1] = "Insert 4-2"
  names[#names+1] = "Octave"
  names[#names+1] = "Gate Length"
  names[#names+1] = "Single Note Repeat"
  names[#names+1] = "Sync"
  names[#names+1] = "Shuffle"
  names[#names+1] = "Hold"
  names[#names+1] = "Manual Velocity"
  for o=1,4 do
    table.insert(names, "Octave "..o)
  end
  names[#names+1] = "Octave Shift"
  names[#names+1] = "Octave Shift Up"
  names[#names+1] = "Octave Shift Down"
  names[#names+1] = "MIDI Indicator"
  names[#names+1] = "Rate Indicator"
  names[#names+1] = "Aftertouch"
  names[#names+1] = "Expression"
  names[#names+1] = "Breath"
  names[#names+1] = "Sustain Pedal"
  names[#names+1] = "Velocity/Manual"
  names[#names+1] = "Rate"
  names[#names+1] = "Pattern Enable"
  names[#names+1] = "Pattern Step Count"
  for s=1,16 do
    table.insert(names, "Pattern Step "..s)
  end
  names[#names+1] = "Pattern Length Up"
  names[#names+1] = "Pattern Length Down"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=3}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  for o=1,4 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=-3, max=3}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=128}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=2, max=16}
  for s=1,16 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}

 -- if we want this device type to have its own output count
  if (_G["Rpg-8_outputs"]~=nil) and (_G["Rpg-8_outputs"]>=1) then
-- assign it here
    out_count = _G["Rpg-8_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_matrix_pattern_sequencer"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Pattern Enable"
  names[#names+1] = "Pattern Select"
  names[#names+1] = "Pattern Select in Bank"
  names[#names+1] = "Bank Select"
  for p=1,8 do
    table.insert(names, "Pattern "..p)
  end
  local bnk={"A","B","C","D"}
  for b=1,4 do
    table.insert(names, "Bank "..bnk[b])
  end
  names[#names+1] = "Run"
  names[#names+1] = "Resolution"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-1, max=31}
  data[#data+1] = {min=0, max=7}
  data[#data+1] = {min=0, max=3}
  for p=1,8 do
    data[#data+1] = {min=0, max=1}
  end
  for b=1,4 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=8}

 -- if we want this device type to have its own output count
  if (_G["Matrix_outputs"]~=nil) and (_G["Matrix_outputs"]>=1) then
-- assign it here
    out_count = _G["Matrix_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_combinator"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "Enabled"
  names[#names+1] = "Note On Indicator"
  for r=1,4 do
    table.insert(names, "Rotary "..r)
  end
  for b=1,4 do
    table.insert(names, "Button "..b)
  end
  names[#names+1] = "Run Pattern Devices"
  names[#names+1] = "Bypass All FX"
  names[#names+1] = "Sample Loading Progress"
  names[#names+1] = "Audio In Indicator"
  names[#names+1] = "Audio Out Indicator"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  for r=1,4 do
    data[#data+1] = {min=0, max=127}
  end
  for b=1,4 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-1, max=127}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Combinator_outputs"]~=nil) and (_G["Combinator_outputs"]>=1) then
-- assign it here
    out_count = _G["Combinator_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        if names[i]=="Pitch Bend" then
          items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
          W1_index = #items
        else
          items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      elseif (out_count>1) then
        if names[i]=="Pitch Bend" then
          if o==1 then
            items[#items+1] = {name=names[i].." - To Tempo BPM", input="value", min=1, max=999, output="value"}
            W1_index = #items
          elseif o==2 then
            items[#items+1] = {name=names[i].." - To Tempo Decimal", input="value", min=0, max=999, output="value"}
            W2_index = #items
          elseif o>2 then
            items[#items+1] = {name=names[i].." - Output "..(o-2), input="value", min=out_data[1], max=out_data[2], output="value"}
          end
        else
          items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
        end
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
      local disallow = {
        "meter",
        "reduction",
        "level output",
        "output level",
        "progress",
        "peak", -- remove inside of pulveriser, condition inside document
        "indicat",
        "connected",
        "playing",
        "all",
        "base",
        " led ",
        "mod level",
        "preset",
        "trig",
        "activity",
        "open"
      }
      for dis=1,#disallow do
        if string.lower(names[i]):find(disallow[dis])~=nil then
          Item_is_not_editable[#items] = true
        end
      end

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Pitch Bend Range" then
        Pitch_bend_range_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_spider_audio_merger_splitter"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  for l=1,4 do
    names[#names+1] = "Merge Input "..l.." Left Activity"
  end
  for r=1,4 do
    names[#names+1] = "Merge Input "..r.." Right Activity"
  end
  names[#names+1] = "Split Input Left Activity"
  names[#names+1] = "Split Input Right Activity"

  in_count = #names
  _G["G_names"] = names

  for l=1,4 do
    data[#data+1] = {min=0, max=1}
  end
  for r=1,4 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}

 -- if we want this device type to have its own output count
  if (_G["Spider_audio_outputs"]~=nil) and (_G["Spider_audio_outputs"]>=1) then
-- assign it here
    out_count = _G["Spider_audio_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_spider_cv_merger_splitter"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  for m=1,4 do
    names[#names+1] = "Merge Input "..m.." Activity"
  end
  names[#names+1] = "Split A Input Activity"
  names[#names+1] = "Split B Input Activity"

  in_count = #names
  _G["G_names"] = names

  for m=1,4 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}

 -- if we want this device type to have its own output count
  if (_G["Spider_cv_outputs"]~=nil) and (_G["Spider_cv_outputs"]>=1) then
-- assign it here
    out_count = _G["Spider_cv_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_mixer_14_2"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Master Level"
  names[#names+1] = "Master Left Peak Meter"
  names[#names+1] = "Master Right Peak Meter"
  for a=1,4 do
    names[#names+1] = "Aux "..a.." Return Level"
  end
  for c=1,14 do
    names[#names+1] = "Channel "..c.." Level"
    names[#names+1] = "Channel "..c.." Pan"
    names[#names+1] = "Channel "..c.." EQ On/Off"
    names[#names+1] = "Channel "..c.." Bass Amount"
    names[#names+1] = "Channel "..c.." Treble Amount"
    names[#names+1] = "Channel "..c.." Solo"
    names[#names+1] = "Channel "..c.." Mute"
    for a=1,4 do
      names[#names+1] = "Channel "..c.." Aux "..a.." Send"
      if (a==4) then
        names[#names+1] = "Channel "..c.." Aux "..a.." Pre Fader On/Off"
      end
    end
    names[#names+1] = "Channel "..c.." Peak Meter"
  end

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}
  for a=1,4 do
    data[#data+1] = {min=0, max=127}
  end
  for c=1,14 do
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    for a=1,4 do
      data[#data+1] = {min=0, max=127}
      if (a==4) then
        data[#data+1] = {min=0, max=1}
      end
    end
    data[#data+1] = {min=0, max=20}
  end

 -- if we want this device type to have its own output count
  if (_G["Mixer_14-2_outputs"]~=nil) and (_G["Mixer_14-2_outputs"]>=1) then
-- assign it here
    out_count = _G["Mixer_14-2_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_line_mixer_6_2"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Master Level"
  for c=1,6 do
    names[#names+1] = "Channel "..c.." Level"
    names[#names+1] = "Channel "..c.." Pan"
    names[#names+1] = "Channel "..c.." Solo"
    names[#names+1] = "Channel "..c.." Mute"
    names[#names+1] = "Channel "..c.." Aux Send"
    names[#names+1] = "Channel "..c.." Peak Meter"
  end
  names[#names+1] = "Aux Return Level"
  names[#names+1] = "Aux Pre/Post"
  names[#names+1] = "Master Left Peak Meter"
  names[#names+1] = "Master Right Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  for c=1,6 do
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=-64, max=63}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=20}
  end
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}

 -- if we want this device type to have its own output count
  if (_G["Line_mixer_6-2_outputs"]~=nil) and (_G["Line_mixer_6-2_outputs"]>=1) then
-- assign it here
    out_count = _G["Line_mixer_6-2_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_mix_channel"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Level"
  names[#names+1] = "Pan"
  names[#names+1] = "Width"
  names[#names+1] = "Mute"
  names[#names+1] = "Solo"
  names[#names+1] = "Input Gain"
  names[#names+1] = "Invert Phase"
  names[#names+1] = "Insert Pre"
  names[#names+1] = "Dyn Post EQ"
  names[#names+1] = "LPF On"
  names[#names+1] = "LPF Frequency"
  names[#names+1] = "HPF On"
  names[#names+1] = "HPF Frequency"
  names[#names+1] = "Filters Dyn S/C"
  names[#names+1] = "EQ On"
  names[#names+1] = "EQ E Mode"
  names[#names+1] = "HF Frequency"
  names[#names+1] = "HF Gain"
  names[#names+1] = "HF Bell"
  names[#names+1] = "HF On"
  names[#names+1] = "HMF Frequency"
  names[#names+1] = "HMF Gain"
  names[#names+1] = "HMF Q"
  names[#names+1] = "HMF On"
  names[#names+1] = "LMF Frequency"
  names[#names+1] = "LMF Gain"
  names[#names+1] = "LMF Q"
  names[#names+1] = "LMF On"
  names[#names+1] = "LF Frequency"
  names[#names+1] = "LF Gain"
  names[#names+1] = "LF Bell"
  names[#names+1] = "LF On"
  for r=1,4 do
    table.insert(names, "Rotary "..r)
  end
  for b=1,4 do
    table.insert(names, "Button "..b)
  end
  names[#names+1] = "Inserts Connected"
  names[#names+1] = "Bypass Insert FX"
  names[#names+1] = "To Insert FX Peak Meter"
  names[#names+1] = "From Insert FX Peak Meter"
  names[#names+1] = "Comp On"
  names[#names+1] = "C Threshold"
  names[#names+1] = "C Release"
  names[#names+1] = "C Ratio"
  names[#names+1] = "C Peak"
  names[#names+1] = "C Fast Atk"
  names[#names+1] = "Comp Gain Reduction"
  names[#names+1] = "Gate On"
  names[#names+1] = "G Threshold"
  names[#names+1] = "G Hold"
  names[#names+1] = "G Release"
  names[#names+1] = "G Range"
  names[#names+1] = "G Fast Atk"
  names[#names+1] = "Expander"
  names[#names+1] = "Gate Gain Reduction"
  names[#names+1] = "Key On"
  for f=1,8 do
    names[#names+1] = "FX"..f.." Send On"
    names[#names+1] = "FX"..f.." Send Level"
    names[#names+1] = "FX"..f.." Pre Fader"
  end
  names[#names+1] = "VU Meter"
  names[#names+1] = "VU Meter L"
  names[#names+1] = "VU Meter R"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=-100, max=100}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1000}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  for r=1,4 do
    data[#data+1] = {min=0, max=127}
  end
  for b=1,4 do
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=5}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=5}
  data[#data+1] = {min=0, max=1}
  for f=1,8 do
    data[#data+1] = {min=0, max=1}
    data[#data+1] = {min=0, max=127}
    data[#data+1] = {min=0, max=1}
  end
  data[#data+1] = {min=0, max=32}
  data[#data+1] = {min=0, max=32}
  data[#data+1] = {min=0, max=32}

 -- if we want this device type to have its own output count
  if (_G["Mix_channel_outputs"]~=nil) and (_G["Mix_channel_outputs"]>=1) then
-- assign it here
    out_count = _G["Mix_channel_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

--[[  DEVELOPER'S NOTE:
      The External Midi Instrument can not have a control surface
      applied to it because doing so causes a catastrophic MIDI
      feedback that cripples Reason until the application is restarted.

      Legacy code provided in the event that future releases address
      this issue, enabling use of the EMI in the future.
]]

--[=[
_G["Define_external_midi_instrument"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Keyboard"
  names[#names+1] = "Pitch Bend"
  names[#names+1] = "Mod Wheel"
  names[#names+1] = "Channel Pressure"
  names[#names+1] = "Expression"
  names[#names+1] = "Damper Pedal"
  names[#names+1] = "Breath"
  names[#names+1] = "MIDI Channel"
  names[#names+1] = "Previous MIDI Channel"
  names[#names+1] = "Next MIDI Channel"
  names[#names+1] = "Note On"
  names[#names+1] = "Controller Activity"
  names[#names+1] = "Program Change On/Off"
  names[#names+1] = "Program Change"
  names[#names+1] = "Aftertouch"
  names[#names+1] = "Assignable Knob On/Off"
  names[#names+1] = "CC Assignment"
  for c=1,120 do
    table.insert(names, "CC "..(c-1))
  end
  names[#names+1] = "Previous MIDI Program"
  names[#names+1] = "Next MIDI Program"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=16383}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=15}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=119}
  for c=1,120 do
    data[#data+1] = {min=0, max=127}
  end
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}

 -- if we want this device type to have its own output count
  if (_G["External_midi_outputs"]~=nil) and (_G["External_midi_outputs"]>=1) then
-- assign it here
    out_count = _G["External_midi_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    if names[i]=="Keyboard" then
      items[#items+1] = {name=names[i], input="keyboard"}
      Keyboard_index = #items
      Keyboard_is_enabled = true
    else

      items[#items+1] = {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}

      if names[i]=="Pitch Bend" then
        Pitch_bend_index = #items
      elseif names[i]=="Mod Wheel" then
        Modulation_wheel_index = #items
      elseif names[i]=="Channel Pressure" then
        Channel_pressure_index = #items
      elseif names[i]=="Expression" then
        Expression_index = #items
      elseif names[i]=="Damper Pedal" then
        Damper_index = #items
      elseif names[i]=="Breath" then
        Breath_index = #items
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
end
]=]

_G["Define_pulveriser"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Squash"
  names[#names+1] = "Release"
  names[#names+1] = "Dirt"
  names[#names+1] = "Tone"
  names[#names+1] = "Routing"
  names[#names+1] = "Filter Frequency"
  names[#names+1] = "Peak"
  names[#names+1] = "Filter Mode"
  names[#names+1] = "Tremor to Frequency"
  names[#names+1] = "Follower to Frequency"
  names[#names+1] = "Follower Trig"
  names[#names+1] = "Follower Threshold"
  names[#names+1] = "Follower Attack"
  names[#names+1] = "Follower Release"
  names[#names+1] = "Tremor Rate"
  names[#names+1] = "Tremor Waveform"
  names[#names+1] = "Sync"
  names[#names+1] = "Tremor Spread"
  names[#names+1] = "Tremor Lag"
  names[#names+1] = "Follower to Rate"
  names[#names+1] = "Blend"
  names[#names+1] = "Tremor to Volume"
  names[#names+1] = "Volume"
  names[#names+1] = "Follow"
  names[#names+1] = "Input Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=5}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=8}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=7}
  data[#data+1] = {min=0, max=7}

 -- if we want this device type to have its own output count
  if (_G["Pulveriser_outputs"]~=nil) and (_G["Pulveriser_outputs"]>=1) then
-- assign it here
    out_count = _G["Pulveriser_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_the_echo"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Delay Time"
  names[#names+1] = "Sync"
  names[#names+1] = "Keep Pitch"
  names[#names+1] = "Right Ch Time Offset"
  names[#names+1] = "Ping-Pong Mode"
  names[#names+1] = "Ping-Pong Pan"
  names[#names+1] = "Feedback"
  names[#names+1] = "Right Ch Feedback Offset"
  names[#names+1] = "Diffuse On"
  names[#names+1] = "Diffuse Spread"
  names[#names+1] = "Diffuse Amount"
  names[#names+1] = "Drive Amount"
  names[#names+1] = "Drive Type"
  names[#names+1] = "Filter On"
  names[#names+1] = "Filter Frequency"
  names[#names+1] = "Filter Resonance"
  names[#names+1] = "Envelope"
  names[#names+1] = "Wobble"
  names[#names+1] = "LFO Rate"
  names[#names+1] = "LFO Amount"
  names[#names+1] = "Input Mode"
  names[#names+1] = "Trig"
  names[#names+1] = "Roll Enabled"
  names[#names+1] = "Ducking"
  names[#names+1] = "Dry/Wet Balance"
  names[#names+1] = "Input Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=3}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=3}

 -- if we want this device type to have its own output count
  if (_G["The_echo_outputs"]~=nil) and (_G["The_echo_outputs"]>=1) then
-- assign it here
    out_count = _G["The_echo_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_alligator"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Enabled"
  names[#names+1] = "Pattern Enable"
  names[#names+1] = "Shift"
  names[#names+1] = "Resolution"
  names[#names+1] = "Pattern"
  names[#names+1] = "Shuffle"
  names[#names+1] = "Gate 1 Trig"
  names[#names+1] = "Gate 2 Trig"
  names[#names+1] = "Gate 3 Trig"
  names[#names+1] = "Amp Env Attack"
  names[#names+1] = "Amp Env Decay"
  names[#names+1] = "Amp Env Release"
  names[#names+1] = "High Pass Filter On"
  names[#names+1] = "High Pass Frequency"
  names[#names+1] = "High Pass Resonance"
  names[#names+1] = "High Pass Env Amount"
  names[#names+1] = "High Pass LFO Amount"
  names[#names+1] = "Band Pass Filter On"
  names[#names+1] = "Band Pass Frequency"
  names[#names+1] = "Band Pass Resonance"
  names[#names+1] = "Band Pass Env Amount"
  names[#names+1] = "Band Pass LFO Amount"
  names[#names+1] = "Low Pass Filter On"
  names[#names+1] = "Low Pass Frequency"
  names[#names+1] = "Low Pass Resonance"
  names[#names+1] = "Low Pass Env Amount"
  names[#names+1] = "Low Pass LFO Amount"
  names[#names+1] = "Filter Env Attack"
  names[#names+1] = "Filter Env Decay"
  names[#names+1] = "Filter Env Release"
  names[#names+1] = "LFO Freq"
  names[#names+1] = "LFO Waveform"
  names[#names+1] = "LFOSync"
  names[#names+1] = "High Pass Drive Amount"
  names[#names+1] = "High Pass Phaser Amount"
  names[#names+1] = "High Pass Delay Amount"
  names[#names+1] = "Band Pass Drive Amount"
  names[#names+1] = "Band Pass Phaser Amount"
  names[#names+1] = "Band Pass Delay Amount"
  names[#names+1] = "Low Pass Drive Amount"
  names[#names+1] = "Low Pass Phaser Amount"
  names[#names+1] = "Low Pass Delay Amount"
  names[#names+1] = "Delay Time"
  names[#names+1] = "Delay Feedback"
  names[#names+1] = "DelaySync"
  names[#names+1] = "Delay Pan"
  names[#names+1] = "Phaser Rate"
  names[#names+1] = "Phaser Feedback"
  names[#names+1] = "High Pass Volume"
  names[#names+1] = "High Pass Pan"
  names[#names+1] = "Band Pass Volume"
  names[#names+1] = "Band Pass Pan"
  names[#names+1] = "Low Pass Volume"
  names[#names+1] = "Low Pass Pan"
  names[#names+1] = "Dry Volume"
  names[#names+1] = "Dry Pan"
  names[#names+1] = "Ducking"
  names[#names+1] = "Master Volume"
  names[#names+1] = "Gate 1 Open"
  names[#names+1] = "Gate 2 Open"
  names[#names+1] = "Gate 3 Open"
  names[#names+1] = "Input Peak Meter"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=2}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=32}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=8}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=-64, max=63}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=3}

 -- if we want this device type to have its own output count
  if (_G["Alligator_outputs"]~=nil) and (_G["Alligator_outputs"]>=1) then
-- assign it here
    out_count = _G["Alligator_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil or string.lower(names[i])=="pattern" then
        Item_is_not_editable[#items] = true
      end
    end
  end

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_regroove_mixer"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Pattern Shuffle"
  local bnk={"A","B","C","D"}
  for b=1,4 do
    for p=1,8 do
      table.insert(names, bnk[b]..p.." Groove Ch On")
      table.insert(names, bnk[b]..p.." Groove Amount")
      table.insert(names, bnk[b]..p.." Slide")
      table.insert(names, bnk[b]..p.." Shuffle")
      table.insert(names, bnk[b]..p.." Pre-Align")
      table.insert(names, bnk[b]..p.." Use Global Shuffle")
    end
  end

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=127}
  for b=1,4 do
    for p=1,8 do
      data[#data+1] = {min=0, max=1}
      data[#data+1] = {min=0, max=100}
      data[#data+1] = {min=-120, max=120}
      data[#data+1] = {min=25, max=75}
      data[#data+1] = {min=0, max=1}
      data[#data+1] = {min=0, max=1}
    end
  end

 -- if we want this device type to have its own output count
  if (_G["Regroove_mixer_outputs"]~=nil) and (_G["Regroove_mixer_outputs"]>=1) then
-- assign it here
    out_count = _G["Regroove_mixer_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

 -- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      "peak", -- remove inside of pulveriser, condition inside document
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_Is_reason_document"] = function()
  local rdi = remote.define_items

  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}
  local outputs = {}

  names[#names+1] = "Click On/Off"
  names[#names+1] = "Click Level"
  names[#names+1] = "Tempo"
  names[#names+1] = "Tempo BPM"
  names[#names+1] = "Tempo Decimal"
  names[#names+1] = "Play"
  names[#names+1] = "Stop"
  names[#names+1] = "Rewind"
  names[#names+1] = "Fast Forward"
  names[#names+1] = "Record"
  names[#names+1] = "Song Position"
  names[#names+1] = "Subticks"
  names[#names+1] = "Clear Subticks"
  names[#names+1] = "Loop On/Off"
  names[#names+1] = "Left Loop"
  names[#names+1] = "Left Loop Subticks"
  names[#names+1] = "Clear Left Loop Subticks"
  names[#names+1] = "Right Loop"
  names[#names+1] = "Right Loop Subticks"
  names[#names+1] = "Clear Right Loop Subticks"
  names[#names+1] = "Punched-In"
  names[#names+1] = "Reset Automation Override"
  names[#names+1] = "Undo"
  names[#names+1] = "Redo"
  names[#names+1] = "Auto-quantize"
  names[#names+1] = "Target Track Solo"
  names[#names+1] = "Target Track Mute"
  names[#names+1] = "Any Track Solo"
  names[#names+1] = "Any Track Mute"
  names[#names+1] = "Return To Zero"
  names[#names+1] = "Audio Left Peak Meter"
  names[#names+1] = "Audio Right Peak Meter"
  names[#names+1] = "New Overdub"
  names[#names+1] = "New Alternative Take"
  names[#names+1] = "Precount On/Off"
  names[#names+1] = "Time Position"
  names[#names+1] = "Automation As Performance Controllers"
  names[#names+1] = "Target Track Enable Automation Recording"
  names[#names+1] = "Tap Tempo"
  names[#names+1] = "Pre Count Bars"
  names[#names+1] = "Move Loop Left"
  names[#names+1] = "Move Loop Right"
  names[#names+1] = "Move Loop One bar Left"
  names[#names+1] = "Move Loop One bar Right"
  names[#names+1] = "Big Meter Left"
  names[#names+1] = "Big Meter Right"
  names[#names+1] = "Big Meter Left Peak"
  names[#names+1] = "Big Meter Right Peak"
  names[#names+1] = "Big Meter Left Clipping"
  names[#names+1] = "Big Meter Right Clipping"
  names[#names+1] = "Select Big Meter Channels"
  names[#names+1] = "Meter Mode"
  names[#names+1] = "Peak Hold"
  names[#names+1] = "Reset Meter Clipping"
  names[#names+1] = "Target Track Enable Monitoring"
  names[#names+1] = "Target Track Meter Left"
  names[#names+1] = "Target Track Meter Right"
  names[#names+1] = "Target Track Meter Left Peak"
  names[#names+1] = "Target Track Meter Right Peak"
  names[#names+1] = "Target Track Meter Left Clipping"
  names[#names+1] = "Target Track Meter Right Clipping"
  names[#names+1] = "Target Track Reset Meter Clipping"
  names[#names+1] = "Target Track Enable Tuner"
  names[#names+1] = "Target Track Tuner Pitch Detected"
  names[#names+1] = "Target Track Tuner Note"
  names[#names+1] = "Target Track Tuner Cents"
  names[#names+1] = "Audio Input Peak Meter"
  names[#names+1] = "Audio Output Peak Meter"
  names[#names+1] = "Send All Notes Off"

  in_count = #names
  _G["G_names"] = names

  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=127}
  data[#data+1] = {min=1000, max=999999}
  data[#data+1] = {min=1, max=999}
  data[#data+1] = {min=0, max=999}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=2147483646}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=2147483646}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=2147483646}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=2147483646}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=1, max=4}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=64}
  data[#data+1] = {min=0, max=64}
  data[#data+1] = {min=0, max=64}
  data[#data+1] = {min=0, max=64}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=64}
  data[#data+1] = {min=0, max=4}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=32}
  data[#data+1] = {min=0, max=32}
  data[#data+1] = {min=0, max=32}
  data[#data+1] = {min=0, max=32}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=1}
  data[#data+1] = {min=0, max=11}
  data[#data+1] = {min=-50, max=50}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=20}
  data[#data+1] = {min=0, max=1}

 -- if we want this device type to have its own output count
  if (_G["Document_transport_outputs"]~=nil) and (_G["Document_transport_outputs"]>=1) then
-- assign it here
    out_count = _G["Document_transport_outputs"]
  else
-- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
-- assign it here
      out_count = _G["Global_outputs"]
    else
-- otherwise default to an output count of 1
      out_count = 1
    end
  end

  Is_reason_document = true

-- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] =  {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] =  {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

-- create the warning
  items[#items+1] =  {name="------------------------", input="noinput", output="text"}
  items[#items+1] =  {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] =  {name="========================", input="noinput", output="text"}

-- create the data sources
  for i=1,in_count do
    items[#items+1] =  {name=names[i], input="value", min=data[i].min, max=data[i].max, output="value"}
    local disallow = {
      "meter",
      "reduction",
      "level output",
      "output level",
      "progress",
      " peak",
      "indicat",
      "connected",
      "playing",
      "all",
      "base",
      " led ",
      "mod level",
      "preset",
      "trig",
      "activity",
      "open"
    }
    for dis=1,#disallow do
      if string.lower(names[i]):find(disallow[dis])~=nil then
        Item_is_not_editable[#items] = true
      end
    end
  end
  rdi(items)
  Has_pitch_wheel = Warp_compatible()
end

_G["Define_midi_controller"] = function(ch,ly)
  local rdi = remote.define_items
  local out_data = {0, 4194048}
  local in_count = nil
  local out_count = nil
  local names = {}
  local data = {}
  local items = {}

  local note = {
 -- octave -2
    "C -2",
    "C#-2",
    "D -2",
    "D#-2",
    "E -2",
    "F -2",
    "F#-2",
    "G -2",
    "G#-2",
    "A -2",
    "A#-2",
    "B -2",
 -- octave -1
    "C -1",
    "C#-1",
    "D -1",
    "D#-1",
    "E -1",
    "F -1",
    "F#-1",
    "G -1",
    "G#-1",
    "A -1",
    "A#-1",
    "B -1",
 -- octave 0
    "C  0",
    "C# 0",
    "D  0",
    "D# 0",
    "E  0",
    "F  0",
    "F# 0",
    "G  0",
    "G# 0",
    "A  0",
    "A# 0",
    "B  0",
 -- octave 1
    "C  1",
    "C# 1",
    "D  1",
    "D# 1",
    "E  1",
    "F  1",
    "F# 1",
    "G  1",
    "G# 1",
    "A  1",
    "A# 1",
    "B  1",
 -- octave 2
    "C  2",
    "C# 2",
    "D  2",
    "D# 2",
    "E  2",
    "F  2",
    "F# 2",
    "G  2",
    "G# 2",
    "A  2",
    "A# 2",
    "B  2",
 -- octave 3
    "C  3",
    "C# 3",
    "D  3",
    "D# 3",
    "E  3",
    "F  3",
    "F# 3",
    "G  3",
    "G# 3",
    "A  3",
    "A# 3",
    "B  3",
 -- octave 4
    "C  4",
    "C# 4",
    "D  4",
    "D# 4",
    "E  4",
    "F  4",
    "F# 4",
    "G  4",
    "G# 4",
    "A  4",
    "A# 4",
    "B  4",
 -- octave 5
    "C  5",
    "C# 5",
    "D  5",
    "D# 5",
    "E  5",
    "F  5",
    "F# 5",
    "G  5",
    "G# 5",
    "A  5",
    "A# 5",
    "B  5",
 -- octave 6
    "C  6",
    "C# 6",
    "D  6",
    "D# 6",
    "E  6",
    "F  6",
    "F# 6",
    "G  6",
    "G# 6",
    "A  6",
    "A# 6",
    "B  6",
 -- octave 7
    "C  7",
    "C# 7",
    "D  7",
    "D# 7",
    "E  7",
    "F  7",
    "F# 7",
    "G  7",
    "G# 7",
    "A  7",
    "A# 7",
    "B  7",
 -- octave 8
    "C  8",
    "C# 8",
    "D  8",
    "D# 8",
    "E  8",
    "F  8",
    "F# 8",
    "G  8"
  }

  for c=1,379 do
    if c==1 then
      names[#names+1] = "Pitch Bend"
    elseif c==2 then
      names[#names+1] = "Mod Wheel"
    elseif c==3 then
      names[#names+1] = "Expression"
    elseif c==4 then
      names[#names+1] = "Damper Pedal"
    elseif c==5 then
      names[#names+1] = "Breath"
    elseif (c > 5 and c <=99) or (c > 107 and c <= 123) then
      names[#names+1] = "CC "..(c-6)
    elseif c > 123 and c <= 251 then
      names[#names+1] = "Note "..note[(c-123)].." Velocity"
    elseif c > 251 and c <= 379 then
      names[#names+1] = "Note "..note[(c-251)].." Aftertouch"
    end
  end

  in_count = #names
  _G["G_names"] = names

 --[[NOTE:	the last two arguments define channel and layer.]]

  if (ch==nil) then ch = "?" end

  for c=1,379 do
    if c==1 then
      data[#data+1] = {min=-8192, max=8191}
    else
      data[#data+1] = {min=0, max=127}
    end
  end

 -- if we want this device type to have its own output count
  if (_G["Midi_controller_outputs"]~=nil) and (_G["Midi_controller_outputs"]>=1) then
 -- assign it here
    out_count = _G["Midi_controller_outputs"]
  else
 -- if we want to follow a global output count
    if (_G["Global_outputs"]~=nil) and (_G["Global_outputs"]>=1) then
 -- assign it here
      out_count = _G["Global_outputs"]
    else
 -- otherwise default to an output count of 1
      out_count = 1
    end
  end

 -- tell the script it's a controller and not a device
  Is_midi_controller = true
  Pitch_bend_index = (in_count * out_count) + 1 --380

 -- build the Architecture to fit this device
  Architect(in_count, out_count, data, out_data, ch, ly)

-- create the virtual outputs
  for i=1,in_count do
    for o=1,out_count do
      if (out_count==1) then
        items[#items+1] = {name=names[i].." - Output", input="value", min=out_data[1], max=out_data[2], output="value"}
      elseif (out_count>1) then
        items[#items+1] = {name=names[i].." - Output "..o, input="value", min=out_data[1], max=out_data[2], output="value"}
      end
    end
  end

 -- create the warning
  items[#items+1] = {name="------------------------", input="noinput", output="text"}
  items[#items+1] = {name="*Do Not Use Items Below*", input="noinput", output="text"}
  items[#items+1] = {name="========================", input="noinput", output="text"}

 -- define the data terminal
  items[#items+1] = {name="Data Terminal", input="noinput", output="text"}
  Device_name_command_line_index = #items
 -- define the internals of the terminal
  Build_terminal()
  rdi(items)
--error('in_count='..in_count..", out_count="..out_count..", in_count * out_count="..in_count*out_count..", and yet somehow #items="..#items)
end

-- constructor
-- written:  06/04/2016
function Remote_init(manufacturer, model)
  assert(manufacturer=="DataBridge")
  local model_fmt=string.lower(model)
  local model_prs={}
  local model_fnc="define"
  Device_type = model_fmt -- store a copy of the raw device type
  
  local i, j = string.find(model_fmt, "midi controller") -- detect midi controller
  if (i~=nil) and (j~=nil) then -- if we found one
    local midi_str = nil
    local midi_prs = {}

    midi_str = string.sub(model_fmt, i, j) -- extract a copy of the string "midi controller"
    if j==model_fmt:len() then
      Deck_number = 1
      Deck_clock = 176 + ((Deck_number*8)-1)
    else
      if model_fmt:sub(-1)=="2" then
        Deck_number = 2
        Deck_clock = 176 + ((Deck_number*8)-1)
      end
    end

    Clock_mask = Hex(Deck_clock).."77 7f" -- generate Clock_mask

    for midi in midi_str:gmatch("%w+") do table.insert(midi_prs, midi) end -- parse "midi controller" into two words in a table
    for m=1,#midi_prs do model_fnc = model_fnc .. "_" .. midi_prs[m] end -- create the string for referencing the global function In _G[]
    if (type(_G[model_fnc])=="function") then -- if the function Exists
      _G[model_fnc]("?", nil) -- pass channel agnostic wildcard "?" and nil for no layers
    end
  else -- if this is a device
    for word in model_fmt:gmatch("%w+") do table.insert(model_prs, word) end -- define a dynamic function Based on model name
    for w=1,#model_prs do model_fnc = model_fnc .. "_" .. model_prs[w] end
    if (type(_G[model_fnc])=="function") then _G[model_fnc]() end -- call the dynamic function
  end
end

-- remote data write
-- written: 04/05/2016
function Remote_process_midi(event)
  if Surface_is_initialized then
    if Is_reason_document then
      Process_document(event)
    elseif Is_midi_controller then
      Process_controller(event)
    else
      process_network(event)
    end
  end
end

-- remote data read
-- written: 06/05/2016
function Remote_set_state(changed_items)
  if Surface_is_initialized then
    if Is_reason_document then
      Set_document(changed_items)
    elseif Is_midi_controller then
      Set_controller(changed_items)
    else
      set_network(changed_items)
    end
  end
end

Lua = {
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
function Decode(s)
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

function Encode(s)
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
