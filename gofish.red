Red [Purpose: "go fish in Red, attempt 3"]
#include %pc.red
random/seed now/time

players: ["human" "computer" "human" "computer"]

;processes
setup: [
		pool: shuffle make-deck
		human_hand: clear []
		computer_hand: clear []
		human_books: copy [0]
		computer_books: copy [0]
		books: copy pip
		ai_fish: none

		loop 9 [
			deal human_hand pool
			deal computer_hand pool
		]
		active_player: random/only players
]

empty-check: function [hand] [
	if (empty? hand) [deal hand pool] 
]

request: function [] [
	input: ask "Request a pip in your deck(quit to exit game): "
	if input = "quit" [halt]

	either not (none? find pip input) [
		input
	] [
		print "invalid input" request
]]

search: function [
	request hand
] [
	foreach card hand [
		if card/1 = request [return true]
	]
	false
]

fish: function [
	hand player request 
	/extern 
	pool ai_fish
] [
	print ["Go Fish" newline]  
	deal hand pool
	last_pip: hand/(length? hand)/1

	if player = "computer" [
		if (search last_pip (copy/part hand (length? hand) - 1)) = false [
			ai_fish: last_pip
		]
	]
	if last_pip = request [
		prin ["Drawn Card: "] contents reduce [hand/(length? hand)]
]]


give: function [
	request giver_hand asker_hand
] [
	while [not (empty? giver_hand)] [ 
		either (giver_hand/1/1 = request) [
			move giver_hand asker_hand 
		] [
			giver_hand: next giver_hand
		]
]]

book-check: function [
	hand player_books
	/extern
	books
] [
	completed: clear []
	foreach book books [
		counter: 0 record: clear []
		repeat card_numb length? hand [
			if hand/:card_numb/1 = book [
				counter: counter + 1
				append/only record hand/:card_numb
		]]
		if counter = 4 [
			head clear insert hand exclude hand record
			append completed book
			player_books/1: player_books/1 + 1
			print ["Book: " book "completed." newline]
		]
	]
	foreach book completed [remove find books book]
]

ai: function [
	/extern
	ai_fish
] [
	either (none? ai-fish) [
		first random/only computer_hand 
	] [
		computer_request: ai-fish ai-fish: none 
		computer_request 
]]

;game flow
turn: function [
	/extern
	active_player pool
] [
	forever [
		either active_player = "human" [
			active_hand: human_hand active_books: human_books
			passive_hand: computer_hand passive_books: computer_books
		] [
			active_hand: computer_hand active_books: computer_books
			passive_hand: human_hand passive_books: human_books
		]

		book-check active_hand active_books
		book-check passive_hand passive_books
		empty-check active_hand empty-check passive_hand
	
		if tail? active_hand [break]

		either active_player = "human" [
			print "Your hand: " contents human_hand print newline 
			until [
				search (choice: request) human_hand
			]
		] [
			choice: ai print ["Computer's choice: " choice]
		]

		either (search choice passive_hand) = true [
			give choice passive_hand active_hand
		] [
			fish active_hand active_player choice
			break
	]]

	active_player: select players active_player
	print ["Remaining Books" reduce books] ask ""
]

demo: function [] [
	do setup
	while [computer_books/1 + human_books/1 < 13] [
		turn
	]
	print ["Computer Books: " computer_books/1 "^/Human Books: " human_books/1]
	either human_books/1 > computer_books/1 [
		print "You Win"
	] [
		print "You lose"
]]

;testing bay
demo
