////////////////////////////////////////////////////////////
//  CURSE DATUM
////////////////////////////////////////////////////////////

/datum/modular_curse
	var/name
	var/expires
	var/flavor
	var/chance
	var/cooldown
	var/last_trigger = 0
	var/trigger
	var/effect
	var/list/effect_args
	var/admin
	var/reason
	var/mob/owner
	var/list/signals = list()

/datum/modular_curse/proc/attach_to_mob(mob/M)
	owner = M

	switch(trigger)
		if("on death")
			RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DEATH
		if("on beheaded")
			RegisterSignal(M, COMSIG_MOB_DECAPPED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DECAPPED
		if("on dismembered")
			RegisterSignal(M, COMSIG_MOB_DISMEMBER, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DISMEMBER
		if("on sleep")
			RegisterSignal(M, COMSIG_LIVING_STATUS_SLEEP, PROC_REF(on_signal_trigger))
			signals += COMSIG_LIVING_STATUS_SLEEP
		if("on attack")
			RegisterSignal(M, COMSIG_MOB_ATTACK_HAND, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_ATTACK_HAND
			RegisterSignal(M, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_ITEM_ATTACK
			RegisterSignal(M, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_ATTACK_RANGED
		if("on receive damage")
			RegisterSignal(M, COMSIG_MOB_APPLY_DAMGE, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_APPLY_DAMGE
		if("on cast spell")
			RegisterSignal(M, COMSIG_MOB_CAST_SPELL, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_CAST_SPELL
		if("on spell or miracle target")
			RegisterSignal(M, COMSIG_MOB_RECEIVE_MAGIC, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_RECEIVE_MAGIC
		if("on cut tree")
			RegisterSignal(M, COMSIG_MOB_FELL_TREE, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_FELL_TREE
		if("on orgasm")
			RegisterSignal(M, COMSIG_MOB_EJACULATED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_EJACULATED
		if("on move")
			RegisterSignal(M, COMSIG_MOVABLE_MOVED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOVABLE_MOVED
		if("on dawn")
			RegisterSignal(M, COMSIG_MOB_DAWNED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DAYED
		if("on day")
			RegisterSignal(M, COMSIG_MOB_DAYED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DAYED
		if("on dusk")
			RegisterSignal(M, COMSIG_MOB_DUSKED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_DAYED
		if("on night")
			RegisterSignal(M, COMSIG_MOB_NIGHTED, PROC_REF(on_signal_trigger))
			signals += COMSIG_MOB_NIGHTED

	// spawn trigger fires instantly
	if(trigger == "on spawn")
		check_trigger("on spawn")

/datum/modular_curse/proc/trigger_effect()
	if(!owner)
		return

	var/mob/living/L = owner
	var/arg = TRUE
	switch(effect)
		if("buff or debuff")
			var/debuff_id = effect_args["debuff_id"]
			if(!debuff_id || !istype(debuff_id, /datum/status_effect))
				return
			L.apply_status_effect(debuff_id)
		if("remove trait")
			var/trait_id = effect_args["trait"]
			if(!trait_id)
				return
			if(HAS_TRAIT(L, trait_id))
				REMOVE_TRAIT(L, trait_id, TRAIT_GENERIC)
			else
				arg = FALSE
		if("add trait")
			var/trait_id = effect_args["trait"]
			if(!trait_id)
				return
			if(HAS_TRAIT(L, trait_id))
				arg = FALSE
			else
				ADD_TRAIT(L, trait_id, TRAIT_GENERIC)
		if("add 2u reagent")
			var/reagent_type = effect_args["reagent_type"]

			if(istext(reagent_type))
				reagent_type = text2path(reagent_type)

			if(!reagent_type)
				return

			var/mob/living/carbon/M = L
			var/datum/reagents/reagents = new()
			reagents.add_reagent(reagent_type, 2)
			reagents.trans_to(M, 2, transfered_by = M, method = INGEST)
		if("add arousal")
			L.sexcon.arousal += 5
		if("shrink sex organs")
			spawn(0)
				var/obj/item/organ/penis/penis = L.getorganslot(ORGAN_SLOT_PENIS)
				var/obj/item/organ/testicles/testicles = L.getorganslot(ORGAN_SLOT_TESTICLES)
				var/obj/item/organ/breasts/breasts = L.getorganslot(ORGAN_SLOT_BREASTS)
				arg = ""
				if(penis)
					if(penis.penis_size > MIN_PENIS_SIZE)
						penis.penis_size--
						arg+= "penis"
				if(testicles)
					if(testicles.ball_size > MIN_TESTICLES_SIZE)
						testicles.ball_size--
						arg+= "testicles"
				if(breasts)
					if(breasts.breast_size > MIN_BREASTS_SIZE )
						breasts.breast_size--
						arg+= "breasts"
				L.update_body()
		if("enlarge sex organs")
			spawn(0)
				var/obj/item/organ/penis/penis = L.getorganslot(ORGAN_SLOT_PENIS)
				var/obj/item/organ/testicles/testicles = L.getorganslot(ORGAN_SLOT_TESTICLES)
				var/obj/item/organ/breasts/breasts = L.getorganslot(ORGAN_SLOT_BREASTS)
				arg = ""
				if(penis)
					if(penis.penis_size < MAX_PENIS_SIZE)
						penis.penis_size++
						arg+= "penis"
				if(testicles)
					if(testicles.ball_size < MAX_TESTICLES_SIZE)
						testicles.ball_size++
						arg+= "testicles"
				if(breasts)
					if(breasts.breast_size < MAX_BREASTS_SIZE )
						breasts.breast_size++
						arg+= "breasts"
				L.update_body()
		if("nauseate")
			var/mob/living/carbon/M = L
			M.add_nausea(4)
		if("clothesplosion")
			L.drop_all_held_items()
			// Remove all clothing except collar
			for(var/obj/item/I in L.get_equipped_items())
				L.dropItemToGround(I, TRUE)
		if("slip")
			spawn(0)
				L.liquid_slip(total_time = 1 SECONDS, stun_duration = 1 SECONDS, height = 12, flip_count = 0)
			/*
		if("jail in arcyne walls")
			var/turf/target = get_turf(L)

			for(var/turf/affected_turf in view(1, L))
				if(!(affected_turf in view(L)))
					continue
				if(get_dist(L, affected_turf) != 1)
					continue
				new /obj/effect/temp_visual/trap_wall(affected_turf)
				addtimer(CALLBACK(src, PROC_REF(/obj/effect/proc_holder/spell/invoked/forcewall/new_wall), affected_turf, L), wait = 0 SECONDS)
				/obj/effect/proc_holder/spell/invoked/forcewall/proc/new_wall(var/turf/target, mob/user)
	new wall_type(target, user)
		if("make deadite")
			if(istype(L, /mob/living/carbon/human))	
				var/mob/living/carbon/human/H = L
				H.transform_into_deadite()
		if("make vampire")
			if(istype(L, /mob/living/carbon/human))	
				var/mob/living/carbon/human/H = L
				H.transform_into_vampire()
		if("make werewolf")
			if(istype(L, /mob/living/carbon/human))	
				var/mob/living/carbon/human/H = L
				H.transform_into_werewolf()*/
		if("shock")
			L.electrocute_act(rand(15,30), src)
		if("add fire stack")
			L.adjust_fire_stacks(rand(1,6))
			L.ignite_mob()
		/*if("easy ambush")
			var/mob/living/simple_animal/M = effect_args["mob_type"]
			if(!M || !istype(M, /mob/living/simple_animal))
				return
			ambush_mob_at_target(L, M, easy = TRUE)
		if("difficult ambush")
			var/mob/living/simple_animal/M = effect_args["mob_type"]
			if(!M || !istype(M, /mob/living/simple_animal))
				return
			ambush_mob_at_target(L, M, easy = FALSE)*/
		if("explode")
			explosion(get_turf(L), 1, 2, 3, 0, TRUE, TRUE)
		/*
		if("nugget")
			if(istype(L, /mob/living/carbon/human))	
				var/mob/living/carbon/human/H = L
				H.spawn_gold_nugget()*/
		if("shapeshift")
			spawn(0)
				var/obj/shapeshift_holder/H = locate() in L
				if(H)
					arg = FALSE
				//var/obj/effect/track/the_evidence = new(L.loc)
				//the_evidence.handle_creation(caster)
				//the_evidence.track_type = "mixture of shifted animal and humanoid tracks"
				//the_evidence.ambiguous_track_type = "curious footprints"
				//the_evidence.base_diff = 6 // very noticable
				var/mob/living/shape = effect_args["mob_type"]

				H = new(shape,src,L)
				//shape.name = "[shape] ([caster.real_name])"
				playsound(L.loc, pick('sound/combat/gib (1).ogg','sound/combat/gib (2).ogg'), 200, FALSE, 3)
				L.spawn_gibs(FALSE)

		if("un-shapeshift")
			spawn(0)
				var/obj/shapeshift_holder/H = locate() in L
				if(!H)
					arg = FALSE
				H.restore()
		if("gib")
			if(!L)
				return
			message_admins(span_adminnotice("[key_name_admin(owner)] gibbed due to curse."))
			SSblackbox.record_feedback("tally", "curse", 1, "Gib Curse") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living, gib), 1, 1, 1), 2)
			return

		else
			// Unknown effect
			return

	notify_player_of_effect(arg)

/datum/modular_curse/proc/notify_player_of_effect(arg)
	if(!owner)
		return
	var/flavor_text_self = ""
	var/flavor_text_other = ""
	var/trigger_text_self = ""
	var/trigger_text_other = ""
	var/effect_text_self = ""
	var/effect_text_other = ""
	var/list/choices_self = list()
	var/list/choices_other = list()
	switch(flavor)
		if("divine")
			choices_self = list(
				"A divine glow surrounds you briefly",
				"A warm light envelops you momentarily",
				"You feel touched by a higher power",
				"A serene calm washes over you",
				"You sense a benevolent presence nearby"
			)
			choices_other = list(
				"A divine glow surrounds [owner] briefly",
				"A warm light envelops [owner] momentarily",
				"[owner] looks touched by a higher power",
				"A serene calm washes over [owner]",
				"[owner] seems to sense a benevolent presence nearby"
			)
		if("demonic")
			choices_self = list(
				"A dark shadow looms over you briefly",
				"A chilling presence envelops you momentarily",
				"You feel tainted by a malevolent force",
				"A sinister chill runs down your spine",
				"You sense an ominous presence nearby"
			)
			choices_other = list(
				"A dark shadow looms over [owner] briefly",
				"A chilling presence envelops [owner] momentarily",
				"[owner] looks tainted by a malevolent force",
				"A sinister chill runs down [owner]'s spine",
				"[owner] seems to sense an ominous presence nearby"
			)
		if("witchcraft")
			choices_self = list(
				"You feel the stirrings of ancient magic within you",
				"A mystical energy courses through your veins",
				"You sense the presence of old spells around you",
				"A faint magical aura surrounds you briefly",
				"You feel connected to the arcane forces"
			)
			choices_other = list(
				"[owner] seems to be surrounded by a mystical energy",
				"A faint magical aura surrounds [owner] briefly",
				"[owner] looks touched by ancient magic",
				"You sense the presence of old spells around [owner]",
				"[owner] appears connected to arcane forces"
			)
		if("fey")
			choices_self = list(
				"You feel the playful touch of the fey",
				"A whimsical energy surrounds you briefly",
				"You sense the mischievous presence of fae beings",
				"A light, airy feeling washes over you",
				"You feel connected to the enchanting forces of nature"
			)
			choices_other = list(
				"[owner] seems to be surrounded by a whimsical energy",
				"A light, airy feeling washes over [owner]",
				"[owner] looks touched by the playful fey",
				"You sense the mischievous presence of fae beings around [owner]",
				"[owner] appears connected to the enchanting forces of nature"
			)
			
		if("mutation")
			choices_self = list(
				"You feel a strange transformation overtaking you",
				"A bizarre energy courses through your body",
				"You sense an unusual change happening within you",
				"A peculiar sensation spreads through your limbs",
				"You feel connected to chaotic forces of mutation"
			)
			choices_other = list(
				"[owner] seems to be undergoing a strange transformation",
				"A bizarre energy courses through [owner]'s body",
				"[owner] looks like they're changing in an unusual way",
				"A peculiar sensation spreads through [owner]'s limbs",
				"[owner] appears connected to chaotic forces of mutation"
			)
	flavor_text_self = pick(choices_self)
	flavor_text_other = pick(choices_other)

	switch(trigger)
		if("on death")
			trigger_text_self = "dying"
			trigger_text_other = "they die"
		if("on beheaded")
			trigger_text_self = "being decapitated"
			trigger_text_other = "they are decapitated"
		if("on dismembered")
			trigger_text_self = "losing a body part"
			trigger_text_other = "they lose a body part"
		if("on sleep")
			trigger_text_self = "falling asleep"
			trigger_text_other = "they fall asleep"
		if("on attack")
			trigger_text_self = "attacking"
			trigger_text_other = "they attack"
		if("on receive damage")
			trigger_text_self = "taking damage"
			trigger_text_other = "they take damage"
		if("on cast spell")
			trigger_text_self = "casting a spell"
			trigger_text_other = "they cast a spell"
		if("on spell or miracle target")
			trigger_text_self = "being targeted by magic"
			trigger_text_other = "they are targeted by magic"
		if("on cut tree")
			trigger_text_self = "felling a tree"
			trigger_text_other = "they fell a tree"
		if("on orgasm")
			trigger_text_self = "orgasming"
			trigger_text_other = "they have an orgasm"
		if("on move")
			trigger_text_self = "moving"
			trigger_text_other = "they move around"
		if("on dawn")
			trigger_text_self = "dawn breaking"
			trigger_text_other = "the dawn breaks"
		if("on day")
			trigger_text_self = "daytime arriving"
			trigger_text_other = "the daytime arrives"
		if("on dusk")
			trigger_text_self = "dusk falling"
			trigger_text_other = "the dusk falls"
		if("on night")
			trigger_text_self = "night falling"
			trigger_text_other = "the night falls"

	switch(effect)
		if("buff or debuff")
			effect_text_self = "a change within yourself"
			effect_text_other = "they seem different somehow"
		if("remove trait")
			effect_text_self = "a part of you fade away"
			effect_text_other = "they seem different somehow"
		if("add trait")
			effect_text_self = "a new aspect of yourself emerge"
			effect_text_other = "they seem different somehow"
		if("add 2u reagent")
			effect_text_self = "your blood to feel different"
			effect_text_other = "they seem different somehow"
		if("add arousal")
			effect_text_self = "you to become aroused"
			effect_text_other = "they seem aroused"
		if("shrink sex organs")
			effect_text_self = "your sex organs to shrink"
			effect_text_other = "they seem to have smaller sex organs"
		if("enlarge sex organs")	
			effect_text_self = "your sex organs to enlarge"
			effect_text_other = "they seem to have larger sex organs"
		if("nauseate")
			effect_text_self = "you to become nauseated"
			effect_text_other = "they look nauseated"
		if("clothesplosion")
			effect_text_self = "your clothes to suddenly fly off"
			effect_text_other = "suddenly, their clothes fly off"
		if("slip")
			effect_text_self = "you to slip and fall"
			effect_text_other = "they slip"
		if("shock")
			effect_text_self = "you to be shocked"
			effect_text_other = "they are shocked"
		if("add fire stack")
			effect_text_self = "you to be set ablaze"
			effect_text_other = "they are set ablaze"
		if("explode")
			effect_text_self = "you to explode"
			effect_text_other = "they are caught in a sudden explosion"
		if("shapeshift")
			effect_text_self = "you to change forms"
			effect_text_other = "they change forms"
		if("un-shapeshift")
			effect_text_self = "you to return to normal"
			effect_text_other = "they change forms"
		if("gib")
			effect_text_self = "you to violently break apart"
			effect_text_other = "they violently break apart"

	var/self_message = "[flavor_text_self] as [trigger_text_self] causes [effect_text_self]"
	var/others_message = "[flavor_text_other]. As [trigger_text_other] [effect_text_other]!"
	owner.visible_message(span_warning(others_message),span_warning(self_message))

/datum/modular_curse/proc/on_signal_trigger()
	if(!owner)
		return
	check_trigger(trigger)

/datum/modular_curse/proc/detach()
	unregister_all_signals()
	owner = null
	signals = list()
	qdel(src)

/datum/modular_curse/proc/check_trigger(trigger_name)
	if(!owner)
		return

	if(trigger != trigger_name)
		return

	if(expires <= now_days())
		var/ck = owner?.ckey
		detach()
		if(ck)
			remove_player_curse(ck, name)
		return

	// cooldown
	if(world.time < last_trigger + (cooldown * 10))
		return

	if(!prob(chance))
		return

	last_trigger = world.time
	trigger_effect()

/datum/modular_curse/proc/unregister_all_signals()
	if(!owner || !signals || !signals.len)
		return

	for(var/S in signals)
		UnregisterSignal(owner, S)

	signals.Cut()

////////////////////////////////////////////////////////////
//  TIME HELPER
////////////////////////////////////////////////////////////

/proc/now_days()
	return round((world.realtime / 10) / 86400)

////////////////////////////////////////////////////////////
//  JSON LOAD / SAVE
////////////////////////////////////////////////////////////

/proc/get_player_curses(key)
	if(!key)
		return

	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")

	var/list/json = json_decode(file2text(json_file))
	if(!json)
		json = list()

	return json


/proc/has_player_curse(key, curse)
	if(!key || !curse)
		return FALSE

	var/list/json = get_player_curses(key)
	if(!json || !json[curse])
		return FALSE

	var/list/C = json[curse]

	if(C["expires"] <= now_days())
		remove_player_curse(key, curse)
		return FALSE

	return TRUE


/proc/apply_player_curse(
	key,
	curse,
	flavor = "divine",
	duration_days = 1,
	cooldown_seconds = 0,
	chance_percent = 100,
	trigger = null,
	effect_proc = null,
	list/effect_args = null,
	admin_name = "unknown",
	reason = "No reason supplied."
)
	if(!key || !curse)
		return FALSE

	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")

	var/list/json = json_decode(file2text(json_file))
	if(!json)
		json = list()

	if(json[curse])
		return FALSE

	json[curse] = list(
		"expires"      = now_days() + duration_days,
		"flavor"       = flavor,
		"chance"       = chance_percent,
		"cooldown"     = cooldown_seconds,
		"last_trigger" = 0,
		"trigger"      = trigger,
		"effect"       = effect_proc,
		"effect_args"  = effect_args,
		"admin"        = admin_name,
		"reason"       = reason
	)

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	// Live-refresh if they're online
	refresh_player_curses_for_key(key)

	return TRUE


/proc/remove_player_curse(key, curse_name)
	if(!key || !curse_name)
		return FALSE

	// --- Load JSON ---
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")

	var/list/json = json_decode(file2text(json_file))
	if(!json || !json[curse_name])
		return FALSE

	// --- Remove from JSON ---
	json[curse_name] = null

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	// --- Live cleanup if player online ---
	for(var/client/C in GLOB.clients)
		if(C && C.ckey == key)
			var/mob/M = C.mob
			if(!M || !M.mind || !M.mind.curses)
				break

			if(M.mind.curses[curse_name])
				var/datum/modular_curse/CR = M.mind.curses[curse_name]

				if(CR)
					CR.detach()

				M.mind.curses -= curse_name

			break

	return TRUE




////////////////////////////////////////////////////////////
//  LIVE REFRESH TO MIND / MOB
////////////////////////////////////////////////////////////

/proc/load_curses_into_mind(datum/mind/M, key)
	if(!M || !key)
		return

	var/list/json = get_player_curses(key)
	if(!json)
		json = list()

	if(!M.curses)
		M.curses = list()

	for(var/existing in M.curses)
		if(!(existing in json))
			var/datum/modular_curse/oldC = M.curses[existing]
			if(oldC)
				oldC.detach()
			M.curses -= existing

	for(var/curse_name in json)
		var/list/C = json[curse_name]
		if(!C)
			continue

		// already exists? update fields
		if(M.curses[curse_name])
			var/datum/modular_curse/existingC = M.curses[curse_name]
			existingC.expires      = C["expires"]
			existingC.flavor      = C["flavor"]
			existingC.chance       = C["chance"]
			existingC.cooldown     = C["cooldown"]
			existingC.last_trigger = C["last_trigger"]
			existingC.trigger      = C["trigger"]
			existingC.effect       = C["effect"]
			existingC.effect_args  = C["effect_args"]
			existingC.admin        = C["admin"]
			existingC.reason       = C["reason"]
			continue

		// create NEW curse datum
		var/datum/modular_curse/newC = new
		newC.name         = curse_name
		newC.expires      = C["expires"]
		newC.flavor      = C["flavor"]
		newC.chance       = C["chance"]
		newC.cooldown     = C["cooldown"]
		newC.last_trigger = C["last_trigger"]
		newC.trigger      = C["trigger"]
		newC.effect       = C["effect"]
		newC.effect_args  = C["effect_args"]
		newC.admin        = C["admin"]
		newC.reason       = C["reason"]

		M.curses[curse_name] = newC

/proc/apply_curses_to_mob(mob/M, datum/mind/MN)
	if(!M || !MN || !MN.curses)
		return

	for(var/curse_name in MN.curses)
		var/datum/modular_curse/C = MN.curses[curse_name]

		if(C.owner == M)
			continue

		C.attach_to_mob(M)


/proc/refresh_player_curses_for_key(key)
	if(!key)
		return

	for(var/client/C in GLOB.clients)
		if(!C || C.ckey != key)
			continue

		var/mob/M = C.mob
		if(!M)
			return

		if(!M.mind)
			M.mind_initialize()

		if(M.mind)
			if(M.mind.curses)
				for(var/datum/modular_curse/CRS in M.mind.curses)
					CRS.detach()
			load_curses_into_mind(M.mind, key)
			apply_curses_to_mob(M, M.mind)
		return



////////////////////////////////////////////////////////////
//  ADMIN POPUP – CURSE CREATION
////////////////////////////////////////////////////////////

/client/proc/curse_player_popup(mob/target)
	if(!target || !target.ckey)
		usr << "Invalid target."
		return

	var/key = target.ckey

	// ---- Trigger Selection ----
	//commented out do not currently have signals
	var/list/trigger_list = list(
		"on spawn",
		"on death",
		"on beheaded",
		"on dismembered",
		"on sleep",
		"on attack",
		"on receive damage",
		"on cast spell",
		"on spell or miracle target",
		//"on break wall/door/window",
		"on cut tree",
		//"on craft",
		"on orgasm",
		//"on bite",
		//"on jump",
		//"on climb",
		//"on swim",
		"on move",
		"on dawn",
		"on day",
		"on dusk",
		"on night"
	)

	var/trigger = input(
		src,
		"Choose a trigger event for this curse:",
		"Trigger Selection"
	) as null|anything in trigger_list

	if(!trigger)
		return

	// ---- Chance ----
	var/chance = input(
		src,
		"Percent chance (1 to 100):",
		"Chance",
		100
	) as null|num

	if(isnull(chance))
		return
	chance = clamp(chance, 1, 100)

	// ---- Effect Selection ----
	var/list/effect_list = list(
		"buff or debuff",
		"remove trait",
		"add trait",
		"add 2u reagent",
		"add arousal",
		"shrink sex organs",
		"enlarge sex organs",
		"nauseate",
		"clothesplosion",
		"slip",
		//"jail in arcyne walls",
		//"make deadite",
		//"make vampire",
		//"make werewolf",
		"shock",
		"add fire stack",
		//"cbt",
		//"easy ambush",
		//"difficult ambush",
		"explode",
		//"nugget",
		"shapeshift",
		"un-shapeshift",
		//"gib and reset body",
		"gib"
	)

	var/effect_proc = input(
		src,
		"Choose the effect this curse will apply:",
		"Effect Selection"
	) as null|anything in effect_list

	if(!effect_proc)
		return

	var/list/effect_args = null

	// ---- Trait selection ----
	if(effect_proc == "add trait" || effect_proc == "remove trait")
		var/list/trait_choices = GLOB.roguetraits.Copy()

		var/action = (effect_proc == "add trait" ? "add" : "remove")

		var/trait_id = input(
			src,
			"Select the trait to [action]:",
			"Trait Selection"
		) as null|anything in trait_choices

		if(!trait_id)
			return

		effect_args = list("trait" = trait_id)

	// ---- Buff / Debuff selection ----
	if(effect_proc == "buff or debuff")
		var/debuff_id = input(
			src,
			"Select the effect to apply:",
			"Effect Selection"
		) as null|anything in subtypesof(/datum/status_effect)

		if(!debuff_id)
			return

		effect_args = list(
			"debuff_id" = debuff_id
		)

	// ---- Reagent selection ----
	if(effect_proc == "add 2u reagent")
		var/reagent_type = input(
			src,
			"Select the reagent to add (typepath):",
			"Reagent Selection"
		) as null|anything in subtypesof(/datum/reagent)

		if(!reagent_type)
			return

		effect_args = list(
			"reagent_type" = reagent_type
		)

	// ---- Mob-spawning effects ----
	if(effect_proc in list("shapeshift", "easy ambush", "difficult ambush"))
		var/mob_type = input(
			src,
			"Select the mob to spawn/give:",
			"Mob Selection"
		) as null|anything in subtypesof(/mob/living/simple_animal)

		if(!mob_type)
			return

		effect_args = list(
			"mob_type" = mob_type
		)

	// ---- Duration ----
	var/duration = input(
		src,
		"Duration (REAL WORLD DAYS):",
		"Duration",
		3
	) as null|num

	if(!duration || duration <= 0)
		return

	// ---- Cooldown ----
	var/cooldown = input(
		src,
		"Cooldown between activations (seconds):",
		"Cooldown",
		1
	) as null|num

	if(cooldown < 0)
		cooldown = 0

	// ---- Reason ----
	var/reason = input(
		src,
		"Reason for curse (admin note):",
		"Reason",
		"Change me or I determine you shitmin"
	) as null|text

	var/list/flavor_list = list(
		"divine",
		"demonic",
		"witchcraft",
		"fey",
		"mutation"
	)

	// ---- Flavor ----
	var/flavor = input(
		src,
		"Flavor of curse (effects player notifications):",
		"Flavor"
	) as null|anything in flavor_list

	// ---- Generate name ----
	var/cname_safe_effect = replacetext(effect_proc, " ", "_")
	var/cname_safe_trigger = replacetext(trigger, " ", "_")
	var/curse_name = "[chance]percent_[cname_safe_effect]_[cname_safe_trigger]_[rand(1000,9999)]"

	// ---- Apply ----
	var/success = apply_player_curse(
		key,
		curse_name,
		flavor,
		duration,
		cooldown,
		chance,
		trigger,
		effect_proc,
		effect_args,
		usr.ckey,
		reason
	)

	if(success)
		src << "<span class='notice'>Applied curse <b>[curse_name]</b> to [target].</span>"
		target << "<span class='warning'>A strange curse settles upon you…</span>"
	else
		src << "<span class='warning'>Failed to apply curse.</span>"
