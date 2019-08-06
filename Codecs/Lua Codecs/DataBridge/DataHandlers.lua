--[=[
  Description:

  The following code isolates the core data handling
  functions used within Data Bridge.

  It is provided here to allow for a better understanding
  of the design, abstracted away from the I/O in the final
  build.
  
]=]

-- data network data write
-- written: 04/05/2016
function process_network(event)
  local rgtm = remote.get_time_ms
  local rmm = remote.match_midi
  local rhi = remote.handle_input

  -- first we handle panic state
  set_ui("panic", event)

  -- if the global data network is running
  if (network_enabled()) then
    -- handle edit events
    set_ui("edit_min", event)
    set_ui("edit_max", event)
    -- handle data processing variants
    set_ui("values", event)

    -- process data sources
    for i=1, surface.i_count do
      -- if we are editing
      if (editing()) or (editing_physics()) or (editing_interpolation()) then
        -- store the state of the comparator for processing
        local i_comp_l = surface.item[i].comparator.last
        local i_comp_t = surface.item[i].comparator.this
        -- if we are editing physics or editing interpolation
        if (editing_physics()) or (editing_interpolation()) then
          -- ignore them
          -- physics is handled by the MIDI controller surface type only
          -- interpolation is handled by virtual outputs only
        -- if we are editing minimum and maximum values
        elseif (editing()) then
          -- if we are editing minimum values
          if (editing_min()) then
            -- if data needs to be processed
            if (data_needs_processing(i_comp_t, i_comp_l)) then
              -- commit the data to the edit event
              apply_item_edit_data(i, "min", i_comp_t)
            end
          end
          -- if we are editing maximum values
          -- NOTE: user can edit min and max at the same time for static values
          if (editing_max()) then
            -- if data needs to be processed
            if (data_needs_processing(i_comp_t, i_comp_l)) then
              -- commit the data to the edit event
              apply_item_edit_data(i, "max", i_comp_t)
            end
          end
				end
      else
        -- \\\\\\\\\\\\\\\\
        -- normal data flow across the global data network
        -- \\\\\\\\\\\\\\\\

        -- if the latch is closed
        if (surface.item[i].comparator.latch==1) then
          -- re-open the latch
          surface.item[i].comparator.latch = 0
        end
        -- store the data packet
        local fthis = surface.item[i].packet.this
        local flast = surface.item[i].packet.last

        -- if there has been an adjustment to remote item "i"
        if (fthis~=nil) and (flast~=nil) then
          -- if we need to constrain this item
--[[
          if (surface.item[i].constrain==1) then
            -- define the constraint we need to impose
            local constrain_msg = {
              time_stamp=event.time_stamp,
              item=surface.item[i].idx,
              value=fthis
            }
            -- cancel the constraint condition
            surface.item[i].constrain = 0
            -- commit the constraint
            rhi(constrain_msg)
          end
]]
          -- update the value
          surface.item[i].value = fthis
        end
      end
      -- process virtual outputs
      for o=1, surface.o_count do
        -- if we are editing
        if (editing()) or (editing_physics()) or (editing_interpolation()) then
          -- store the comparator for data processing
          local o_comp_l = surface.item[i].out[o].comparator.last
          local o_comp_t = surface.item[i].out[o].comparator.this
          -- if we are editing physics or editing interpolation
          if (editing_physics()) or (editing_interpolation()) then
            -- if we are specifically editing physics
            if (editing_physics()) then
              -- ignore it
              -- physics is handled by the MIDI controller surface type only
            end
            -- if we are specifically editing interpolation
            -- NOTE: users can edit physics and interpolation at the same time
            if (editing_interpolation()) then
              -- if we are editing the interpolation curve (min value button)
              if (editing_interp_curve()) then
                -- if data needs to be processed
                if (data_needs_processing(o_comp_t, o_comp_l)) then
                  -- curvature editing will occur here
                end
              -- if we are editing the interpolation timing (max value button)
              elseif (editing_interp_time()) then
                -- if data needs to be processed
                if (data_needs_processing(o_comp_t, o_comp_l)) then
                  -- time step editing will occur here
                end
              end
            end
          -- if we are editing minimum and maximum values
          elseif (editing()) then
            -- if we are editing minimum values
            if (editing_min()) then
              -- if data needs to be processed
              if (data_needs_processing(o_comp_t, o_comp_l)) then
                -- commit the data to the edit event
                apply_output_edit_data(i, o, "min", o_comp_t)
              end
            end
            -- if we are editing maximum values
            -- NOTE: users can edit minimum and maximum values at the same time for static values
            if (editing_max()) then
              -- if data needs to be processed
              if (data_needs_processing(o_comp_t, o_comp_l)) then
                -- commit the data to the edit event
                apply_output_edit_data(i, o, "min", o_comp_t)
              end
            end
					end
        else
          -- \\\\\\\\\\\\\\\\
          -- normal data flow across the global data network
          -- \\\\\\\\\\\\\\\\

          -- if the latch is closed
          if (surface.item[i].out[o].comparator.latch==1) then
            -- re-open the latch
            surface.item[i].out[o].comparator.latch = 0
          end

          -- if this output is in use
          if (surface.item[i].out[o].connected) then
            -- store the data packet
            local pthis = surface.item[i].out[o].packet.this
            local plast = surface.item[i].out[o].packet.last
            -- if data has been updated in the global network
            if (pthis~=nil) and (plast~=nil) then
              -- define the adjustment for this virtual output
              local data_packet_msg = {
                time_stamp=event.time_stamp,
                item=surface.item[i].out[o].idx,
                value=pthis
              }
              -- commit the data to the virtual output
              rhi(data_packet_msg)
            end
          end
        end
      end
    end
  end
end

-- data network data read
-- written: 06/05/2016
function set_network(changed_items)
  local riie = remote.is_item_enabled
	--local rgiv = remote.get_item_value
  local rgis = remote.get_item_state

  -- if the global data network is running
	if (network_enabled()) then
	  -- go through each item
	  for i=1, surface.i_count do
	    -- if the surface is locked to a device in the host
	    if (riie(surface.item[i].idx)) then
	      -- extract the state of remote item "i" on the locked device
				--surface.item[i].value = rgiv(surface.item[i].idx)
	      surface.item[i].remote_obj=rgis(surface.item[i].idx)

	      -- if we are editing min and max
	      if (editing()) then
	        -- if the latch is open
	        if (surface.item[i].comparator.latch==0) then
	          -- empty the comparator
	          surface.item[i].comparator.this = nil
	          -- close the latch
	          surface.item[i].comparator.latch = 1
	        end
	        -- populate the comparator
	        surface.item[i].comparator.last = surface.item[i].comparator.this
	        surface.item[i].comparator.this = surface.item[i].remote_obj.value

	      -- if we are editing physics
	      elseif (editing_physics()) or (editing_interpolation()) then
	        -- ignore them
	        -- physics is handled by the MIDI controller surface type only
	        -- interpolation is handled by virtual outputs only
	      else
	        -- \\\\\\\\\\\\\\\\
	        -- normal data flow across the global data network
	        -- \\\\\\\\\\\\\\\\

	        -- store the value of the last state of remote item "i"
					--local adj_i_val = surface.item[i].value
	        local adj_i_val = surface.item[i].remote_obj.value
	        -- create references to minimum and maximum values for this item

					local l_min = surface.item[i].min
	        local l_max = surface.item[i].max
	        -- check for data inversion
	        if (surface.item[i].max < surface.item[i].min) then
	          l_min = surface.item[i].max
	          l_max = surface.item[i].min
	        end
	        -- constrain data to the range [l_min, l_max]
	        if (adj_i_val < l_min) then
	          adj_i_val = l_min
	          surface.item[i].constrain = 1
	        elseif (adj_i_val > l_max) then
	          adj_i_val = l_max
	          surface.item[i].constrain = 1
	        end

	        -- populate the data packet for the current adjustment
	        surface.item[i].packet.last = surface.item[i].packet.this
	        surface.item[i].packet.this = adj_i_val
	      end
	      -- go through the virtual outputs for remote item "i"
	      for o=1, surface.o_count do
	        -- if this virtual output is in use
	        if (riie(surface.item[i].out[o].idx)) then
	          -- extract the state of virtual output "o" (remote override)
						--surface.item[i].out[o].value = rgiv(surface.item[i].out[o].idx)
	          surface.item[i].out[o].remote_obj = rgis(surface.item[i].out[o].idx)
	          -- let the rest of the data handling routines know this output is in use
	          surface.item[i].out[o].connected = true

	          -- if we are editing minimum and maximum values or editing interpolation
	          if (editing()) or (editing_interpolation()) then
	            -- if the latch is open
	            if (surface.item[i].out[o].comparator.latch==0) then
	              -- empty the comparator
	              surface.item[i].out[o].comparator.this = nil
	              -- close the latch
	              surface.item[i].out[o].comparator.latch = 1
	            end
	            -- populate the comparator
	            surface.item[i].out[o].comparator.last = surface.item[i].out[o].comparator.this
							--surface.item[i].out[o].comparator.this = surface.item[i].out[o].value
	            surface.item[i].out[o].comparator.this = surface.item[i].out[o].remote_obj.value
	          elseif (editing_physics()) then
	            -- ignore
	            -- physics is handled by the MIDI controller surface type only
	          else
	            -- \\\\\\\\\\\\\\\\
	            -- normal data flow across the global data network
	            -- \\\\\\\\\\\\\\\\

	            -- store the floating point generated by remote item "i"
	            local adj_value = surface.item[i].value

							local l_min = surface.item[i].min
							local l_max = surface.item[i].max
							if (surface.item[i].max < surface.item[i].min) then
								l_min = surface.item[i].max
								l_max = surface.item[i].min
							end
	            -- reinforce constraints on the data range
	            if (adj_value < l_min) then
	              adj_value = l_min
	            elseif (adj_value > l_max) then
	              adj_value = l_max
	            end

	            -- create the value we will be sending to the data packet
	            local target_val = nil
	            -- create the delta value we will be using to process the data
	            local rel_dlt = nil

	            -- if we are anticipating unipolar data/absolute values (0-127)
	            if (absolute()) then
								target_val = math.floor(surface.item[i].out[o].min + ((adj_value - surface.item[i].min) * surface.item[i].out[o].ratio))
	            -- if we are anticipating bipolar data/relative values (-64-63)
	            elseif (relative()) then
								local i_min = surface.item[i].min
								local i_dlt = surface.item[i].dlt
								local o_min = surface.item[i].out[o].min
								local o_rat = surface.item[i].out[o].ratio
								target_val = math.floor(o_min + (((adj_value - (i_min + (i_dlt * 0.5))) + (i_dlt * 0.5)) * o_rat))
	            end
	            -- populate the data packet
	            surface.item[i].out[o].packet.last = surface.item[i].out[o].packet.this
	            surface.item[i].out[o].packet.this = target_val
	          end
	        -- if this output is not in use
	        else
	          -- let the rest of the data handling routines know this output is not in use
	          surface.item[i].out[o].connected = false
	        end
	      end
	    end
	  end
	end
end
