;--------------------A* TREE SEARCH----------------------------------

;current - current state whose children are explored in one iterative
;frontier - open list
;energy - energy with which is starts

;-------------------A Star TREE----------------------------

(define (a*-tree-search percept energy)
	(a*-tree percept '(0 0 N 0 ()) energy '((0 0 N 0 ())) '()))

(define (a*-tree percept current energy frontier closed)
	;(display frontier)
	;(newline)
(if (goal? percept current) ;if goal is reached
	(append (nth-item 4 current) (list (+ (- energy (nth-item 3 current)) (maxreward (get-goals percept)))))
	(if (< energy (cost current)) "Exhasuted" ;if goal not reached and energy less than minimum required to reach next state, exhausted
    	(a*-tree percept (car (sort (uniqueappend (dropcurrent frontier current) (get-legalchildren current percept energy)) percept energy)) 
    		;next current is first element of sorted list of new frontier which is without current and with children
    		energy 
    		(sort (uniqueappend (dropcurrent frontier current) (get-legalchildren current percept energy)) percept energy);new frontier is without current and with current's children
    		(cons current closed)))))

; (a*-tree-search (percept) 1000)
