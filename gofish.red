Red [Purpose: "Go Fish"]
#include %pc.red
random/seed now/time

players: ["human" "computer" "human" "computer"]

;processes
setup: do [
	pool: shuffle make-deck
	books: copy pip
	ai-fish: none
	computer_hand: clear [] computer_books: 0
	human_hand: clear [] human_books: 0
	loop 9 [deal human_hand pool deal computer_hand pool]
	active_player: random/only players
] 

empty-check: func [hand] [
	if (empty? hand) [deal hand pool] 
]

request: func [] [
	input: ask "Request a pip in your deck(quit to exit game): "
	if input = "quit" [halt]

	either not (none? find pip input) [
		return input
	] [
		print "invalid input" request
	]
]

search: func [request hand] [  
	foreach card hand [
		if (first card) = request [ 
			return true
		]
	]
	return false 
]

fish: func [hand player request] [
	print [newline "Go Fish" newline]  
	either player = "human" [
		deal hand pool
	] [
		deal hand pool
		if (search first last hand take/deep/part copy hand ((length? hand) - 1)) = false [ ;only one instance of pip
			 ai-fish: first last hand
		]
	]
	if (first last hand) = request [
		print ["Drawn card: "] contents reduce [take/deep/last copy hand] print newline
	]
	wait 1 
	return true
]

give: func [request giver_hand asker_hand] [
	while [not (empty? giver_hand)] [ 
		either ((first first giver_hand) = request) [
			move giver_hand asker_hand 
		] [
			giver_hand: next giver_hand
		]
	]
	giver_hand: head giver_hand
]

book-check: func [hand player_books] [ ;add book number tracking
	completed: copy []
	foreach book books [ 
		counter: 0 record: clear [] 
		repeat card-numb length? hand [
			if (first hand/:card-numb) = book [
				counter: counter + 1 append/only record hand/:card-numb
		]]
		if counter = 4 [
			hand: exclude hand record
			append completed book
			player_books: player_books + 1
		] 
	]
	foreach book completed [remove find books book]
	hand 
]

ai: func [] [
	either (none? ai-fish) [
		return first random/only computer_hand 
	] [
		request: ai-fish ai-fish: none 
		return request 
	]
]

;game flow
turn: [
	until [
		either (active_player = "human") [
			book-check computer_hand computer_books
			print [newline "Your hand: " newline] contents human_hand print newline 
			
			until [
				search (choice: request) human_hand 
			]
			
			active_hand: human_hand active_books: human_books 
			passive_hand: computer_hand passive_books: computer_books
		] [
			book-check human_hand human_books
			
			choice: ai 
			print [newline "Computer's choice: " choice newline]
			
			active_hand: computer_hand active_books: computer_books 
			passive_hand: human_hand passive_books: human_books
		]		
		
		either (search choice passive_hand) [
			give choice passive_hand active_hand
			book-check active_hand active_books		
			empty-check passive_hand  
		] [
			fish active_hand active_player choice
		]
	] 

	print [newline "Remaining Books: " books newline]
	
	active_player: select players active_player
]
  
demo: does [
	setup
	while [computer_books + human_books < 13] [
		do turn
	]
	print [newline "Computer books:" computer_books newline "Player books:" human_books]
	either (human_books > computer_books) [
		print "You Win"
	] [
		print "You Lose"
	]
]

;testing bay 
demo
