
/datum/supply_pack/rogue/Medicaments
	group = "Medicaments"
	crate_name = "Gifts of Lyfe"
	crate_type = /obj/structure/closet/crate/chest/merchant

/////////////
// MEDICAL //
/////////////

/datum/supply_pack/rogue/Medicaments/bandages
	name = "Roll of bandages"
	cost = 10
	contains = list(/obj/item/natural/bundle/cloth/bandage/full)

/////////////
// POTIONS //
/////////////

/datum/supply_pack/rogue/Medicaments/healthpotnew
	name = "Health Potion"
	cost = 10
	contains = list(/obj/item/reagent_containers/glass/bottle/rogue/healthpotnew)

/datum/supply_pack/rogue/Medicaments/manapot
	name = "Mana Potion"
	cost = 10
	contains = list(/obj/item/reagent_containers/glass/bottle/rogue/strongmanapot)

/datum/supply_pack/rogue/Medicaments/stampot
	name = "Stamina Potion"
	cost = 10
	contains = list(/obj/item/reagent_containers/glass/bottle/rogue/strongstampot)

/datum/supply_pack/rogue/Medicaments/rotcure
	name = "Rot Cure Potion"
	cost = 200
	contains = list(/obj/item/reagent_containers/glass/bottle/alchemical/rogue/rotcure)

/datum/supply_pack/rogue/Medicaments/emberwine
	name = "Emberwine"
	cost =	150	// It makes a good poison but its moreso to goon with. 
	contains = list(/obj/item/reagent_containers/glass/bottle/rogue/emberwine)

///////////
// DRUGS //
///////////

/datum/supply_pack/rogue/Medicaments/westleach
	name = "Westleach Zig"
	cost = 2
	contains = list(/obj/item/clothing/mask/cigarette/rollie/nicotine)

/datum/supply_pack/rogue/Medicaments/swampweed
	name = "Swampweed Zig"
	cost = 5
	contains = list(/obj/item/clothing/mask/cigarette/rollie/cannabis)

/datum/supply_pack/rogue/Medicaments/ozium
	name = "Ozium"
	cost = 15
	contains = list(/obj/item/reagent_containers/powder/ozium)

/datum/supply_pack/rogue/Medicaments/moondust
	name = "Moon Dust"
	cost = 15
	contains = list(/obj/item/reagent_containers/powder/moondust)

/datum/supply_pack/rogue/Medicaments/spice
	name = "Spice"
	cost = 15
	contains = list(/obj/item/reagent_containers/powder/spice)
