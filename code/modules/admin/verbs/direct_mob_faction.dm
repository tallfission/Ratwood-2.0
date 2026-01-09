/client/proc/mass_direct()
	set name = "Direct Mobs"
	set category = "-GameMaster-"
	if(holder)
		holder.mass_direct_mobs()

/datum/admins/proc/mass_direct_mobs(radius = 20, faction = null)
	if(!check_rights(R_ADMIN))
		return
	
	var/list/valid_factions = list(
		"orcs",
		"undead",
		"caves"
	)
	
	var/faction_options = ""
	for(var/F in valid_factions)
		faction_options += "<option value='[F]' [F == faction ? "selected" : ""]>[F]</option>"
	
	var/dat = {"
		<html>
		<head>
			<title>Mass Direct Mobs</title>
			<style>
				html, body { 
					height: 100%; 
					margin: 0; 
					padding: 0; 
					overflow-x: hidden; 
				}
				body { 
					font-family: Verdana, sans-serif; 
					background-color: #f0f0f0; 
					color: #333; 
					padding: 15px;
				}
				h2 { 
					color: #333; 
					border-bottom: 2px solid #2196F3; 
					padding-bottom: 8px; 
					margin-top: 0;
				}
				.info-section {
					background: white;
					padding: 15px;
					margin: 10px 0;
					border-radius: 5px;
					border: 1px solid #ddd;
				}
				.setting-row {
					margin: 8px 0;
					display: flex;
					align-items: center;
				}
				.setting-label {
					min-width: 80px;
					font-weight: bold;
					color: #333;
				}
				.setting-value {
					color: #2196F3;
					margin: 0 10px;
					font-weight: bold;
				}
				select {
					background-color: white;
					color: #333;
					border: 1px solid #ddd;
					padding: 5px 10px;
					border-radius: 3px;
				}
				button { 
					background-color: #2196F3; 
					color: white; 
					padding: 8px 15px; 
					border: none; 
					cursor: pointer; 
					margin: 5px 0;
					border-radius: 3px;
				}
				button:hover { 
					background-color: #0b7dda; 
				}
				.success {
					background-color: #4CAF50;
				}
				.success:hover {
					background-color: #45a049;
				}
			</style>
		</head>
		<body>
		<h2>Mass Direct Mobs</h2>
		
		<div class='info-section'>
			<div class='setting-row'>
				<span class='setting-label'>Radius:</span>
				<span class='setting-value'>[radius]</span>
				<a href='?src=[REF(src)];[HrefToken()];mass_direct=set_radius;current_radius=[radius];faction=[faction]'><button>Change</button></a>
			</div>
			<div class='setting-row'>
				<span class='setting-label'>Faction:</span>
				<select onchange="window.location='?src=[REF(src)];[HrefToken()];mass_direct=set_faction;radius=[radius];faction=' + this.value">
					<option value=''>Select Faction</option>
					[faction_options]
				</select>
			</div>
		</div>
		"}

	if(faction)
		dat += {"
			<div style='text-align: center; margin-top: 15px;'>
				<a href='?src=[REF(src)];[HrefToken()];mass_direct=begin_targeting;radius=[radius];faction=[faction]'>
					<button class='success' style='padding: 10px 20px; font-size: 14px;'>Begin Directing [faction] Mobs</button>
				</a>
			</div>
			"}
	else
		dat += {"
			<div style='text-align: center; margin-top: 15px; color: #ff9800;'>
				<p>⚠ Please select a faction to continue</p>
			</div>
			"}
	
	dat += {"
		</body>
		</html>
		"}
	
	usr << browse(dat, "window=mass_direct;size=450x350")

/datum/admins/proc/mass_direct_handle_topic(href_list)
	if(!check_rights(R_ADMIN))
		return FALSE
	
	if(!href_list["mass_direct"])
		return FALSE
	
	var/radius = text2num(href_list["radius"]) || text2num(href_list["current_radius"]) || 20
	var/faction = href_list["faction"]
	
	switch(href_list["mass_direct"])
		if("set_radius")
			var/new_radius = input("Enter new radius (1-50):", "Set Radius", radius) as num|null
			if(new_radius)
				radius = clamp(new_radius, 1, 50)
		
		if("set_faction")
			faction = href_list["faction"]
		
		if("begin_targeting")
			if(!faction)
				to_chat(usr, span_warning("No faction selected!"))
				mass_direct_mobs(radius, faction)
				return TRUE
				
			to_chat(usr, span_notice("Click on locations to direct mobs. Right click to stop directing."))
			var/datum/mass_direct_click_intercept/click_handler = new(usr.client, src, radius, faction)
			usr.client.click_intercept = click_handler
			return TRUE
	
	mass_direct_mobs(radius, faction)
	return TRUE

/datum/mass_direct_click_intercept
	var/client/owner
	var/datum/admins/admin_datum
	var/radius
	var/faction

/datum/mass_direct_click_intercept/New(client/C, datum/admins/A, R, F)
	owner = C
	admin_datum = A
	radius = R
	faction = F
	owner.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'

/datum/mass_direct_click_intercept/proc/InterceptClickOn(user, params, atom/target)
	var/list/modifiers = params2list(params)
	if(modifiers["right"])
		cleanup()
		to_chat(user, span_notice("Stopped directing mobs."))
		return TRUE
	
	if(istype(target, /atom/movable/screen))
		return FALSE
	
	var/turf/T = get_turf(target)
	if(!T)
		return TRUE
	
	var/count = 0
	var/list/directed_mobs = list()
	
	for(var/mob/living/M in range(radius, user))
		if(M.client) // Skip player-controlled mobs
			continue
		
		if(!M.faction || !(faction in M.faction)) // Skip mobs not in selected faction
			continue
		
		// Try different approaches for directing the mob
		if(M.ai_controller)
			var/datum/ai_controller/ai = M.ai_controller
			ai.clear_blackboard_key(BB_TRAVEL_DESTINATION)
			ai.set_blackboard_key(BB_TRAVEL_DESTINATION, T)
			directed_mobs += M.name
			count++
		else if(istype(M, /mob/living/simple_animal))
			// For simple animals without ai_controller, try direct targeting
			var/mob/living/simple_animal/SA = M
			if(SA.AIStatus != AI_OFF)
				directed_mobs += SA.name
				count++
	
	if(count > 0)
		to_chat(user, span_notice("Directed [count] [faction] mob[count > 1 ? "s" : ""] towards [AREACOORD(T)]."))
		message_admins("[key_name_admin(user)] directed [count] [faction] mobs to [AREACOORD(T)].")
		log_admin("[key_name(user)] directed [count] [faction] mobs to [AREACOORD(T)].")
	else
		to_chat(user, span_warning("No [faction] mobs found within radius [radius]!"))
	
	return TRUE

/datum/mass_direct_click_intercept/proc/cleanup()
	if(owner)
		owner.click_intercept = null
		owner.mouse_pointer_icon = null
		owner.mob.update_mouse_pointer()
