extends Node

var speaker: String = "speaker"
var dialog: String = "dialog"

const kratos: String = "kratos"
const rick: String = "rick"
const shild: String = "shild"
const kristall: String = "kristall"
const bossDoor: String = "bossDoor"
const houseDoor: String = "houseDoor"
const buschi: String = "buschi"
const graveStone: String = "graveStone"
const enemyGraveStone: String = "enemyGraveStone"

const allText: Array[String] = [kratos, rick, shild, kristall, bossDoor, houseDoor, buschi, graveStone, enemyGraveStone]

const dialogue: Dictionary[String, Dictionary] = {
	kratos:{
		speaker = ["???", kratos, kratos, kratos],
		dialog = [["Who are you? What shall you portray, hollow Knight? So be it. I can't tell you very much. However. Why are you here, What is your task?","You don't know? Oh well. How about collecting the three crystals? This also helps me to get my memory back. Then maybe I can tell you more. To get to a crystal, go through either the door at the top left or at the top right."],
		 	 ["Wow. You got your first crystal. I didn't think you could do that. Can I tell you more now?  What I can tell you is that I can remember my name again. My name is Kratos. What is your name?... You don't have one? But everyone has a name. Why wouldn't you have one?"],
		 	 ["So you did it. 2 of 3 crystals. Now the last gate should be open. Defeat Boss galaga and you will hopefully have reached your goal. The door to Boss Galaga is below us. Just go left or right down the stairs. this guy is so arrogant!"],
		 	 ["You have found All Crystals. Congratulations... But what's in it for you? You want to reach the end? Well, do what you want."]]
	},
	rick:{
		speaker = ["???", "???", "Rick Sanchez", "Rick Sanchez"],
		dialog = [["Hello stranger! I've never seen you here. You're not from here, aren't you? At least it doesn't look like it. I'm sorry. unfortunately I can't introduce myself, but what's your name? You don't know it? Now... Unfortunately, I feel the same way."],
				["you brought back a crystal. If you're wondering why there are only three of us here, that's because... When the crystals disappeared, all the inhabitants lost their names. Including me, and without a name they have no existence.","Names are something associated with us. You can even tell twins apart with names. But you can't live in this world without a name."],
				["Thank you for bringing back two crystals. This makes me remember my name again. That means I can introduce myself to you now. I'm Rick Sanchez. The person on the left is my twin brother.", "If you are wondering why many doors are not accessible, it is because the houses have collapsed. Without a crystal, caves like to collapse. This must have happened when you removed the crystals in the caves.", "There is only one crystal left to be found. But what I'm wondering, why did you collect the crystals? You didn't know about our situation. Neither do we. What was the point. Did anyone tell you to come here and collect the crystals?"],
				["Now all crystals have been collected. But what I've been wondering all the time. Without a name... How could you go on living? you didn't know your name. not even now. Without a name, you die after a short time if you are deprived of it.", "The crystals prevent anyone from losing their name and even now that all the crystals have been collected... You still don't know your name. Are you somehow special?"]]
	},
	shild:{
		speaker = [shild, shild, shild, shild, shild, shild],
		dialog = [["In this game you can jump  (What a suprise). but you can jump higher or lower, depending on how long you hold the jump button (look controlls)"],
				["If you are on a wall and not on the floor, you can use a wall jump, with that you can either climb up walls or jump from wall to wall. To use it. Go next to a wall and press the Jump button.(look controlls)"],
				["Because one Jump would be boring, you have a jump in the air. So use it to jump over the pit. Tipp: The air Jump resets, if you are on floor or if you used a walljump, so you can use it again."],
				["Because this is a brutal killer game, you have a Sword, with which you can atack up to 3 times in a row by pressing the sword button (look controlls), after that you need to wait about 1 sec to attack with it again. go ahead and try it out on the dummy."],
				["Now you learned how to use your Sword. But what about your Wand? You can use a Wand by pressing the wand button (look controlls). with the attack coming out of it, you can also harm enemys. the attack even goes trough walls. use it to press the button inside the wall.", "But be aware. the use of a wand is limited. limited by your mana. its the blue bar thats under your Hpbar (The green bar). so always keep that in mind. but dont worry the mana refills it self over the time."],
				["Something you need to know if your are playing with a friends is, that there is a split screen. You can respawn after 5sec by pressing the (Spawn) Button, if the other player is alive. If you both, died, you can respan instantly", "If you want to know how the 2 Player mode works. go either to the pause menu by pressing the start button on the controller. or go to the main menu. there is a button on the side with two characters on it. just click on it and get a little explanation."]]
	},
	kristall:{
		speaker = "",
		dialog = ["This seems to be a crystal. Maybe I should collect it"]
	},
	bossDoor:{
		speaker = "",
		dialog = ["This door cannot be opened. Maybe it will work if I come back another time", "But this image looks familiar to me. maybe that's a well-known figure"]
	},
	houseDoor:{
		speaker = ["", ""],
		dialog = [["This door does not seem to open. there doesn't seem to be anyone in it either...Why is that?"],
				["Its a shame, that the houses collapsed. I hope that the people survived"]]
	},
	buschi:{
		speaker = [buschi, buschi],
		dialog = [["Hi. I'm Bushie! I came from the garden of souls to visit a friend. If you want to know, why I'm in this Bush. I just like it that way. Its comfortable.", "Oh. and dont worry i'm not a pedophile. If you want i can give you a tutorial about the controlls and your movement. You just have to come into this bush."],
				["do you want to do the tutorial? just come into this bush."]]
	},
	graveStone:{
		speaker = [""],
		dialog = ["every gravestone i walked passed by, had a name written on it. Its from the living creatures i killed, but this one doesn't hava a name written on it, it's just empty. Everyone had a Name, except me. maybe thats my gravestone...", "eveything found his end in her. Maybe i should find my end her too..."]
	},
	enemyGraveStone:{
		speaker = [""],
		dialog = [""]
	}
}
