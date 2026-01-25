extends Weapon


func attack():
	super.attack()
	w_uses_left -=1
	$"..".weapon_update()

func ability():
	super.ability()
