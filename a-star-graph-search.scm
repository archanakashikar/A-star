;--------------------------------------------A* GRAPH SEARCH-----------------------------------------

;current - current state whose children are explored in one iterative
;frontier - open list
;energy - energy with which is starts
;-------------------Graph search helper function----------------------------

(define (visited? current closed) ;to check if current state is visited
(if (null? closed) #f ;if closed is empty, curent cannot visit it
	(if (and (equal? (nth-item 2 (car closed)) (nth-item 2 current))
		(and (= (xcd (car closed)) (xcd current)) (= (ycd (car closed)) (ycd current)))) #t ; if xcd, ycd and direction are same, then it is visited
			(visited? current (cdr closed))))) ;else check for tail part

;------------------A-star graph algo-------------------------------
(define (a*-graph-search percept energy)
	(a*-graph percept '(0 0 N 0 ()) energy '((0 0 N 0 ())) '()))

(define (a*-graph percept current energy frontier closed)
	;(display frontier)
	;(newline)
(if (goal? percept current)  
	(append (nth-item 4 current) (list (+ (- energy (nth-item 3 current)) (maxreward (get-goals percept))))) 
	(if (< energy (cost current)) "Exhausted"
		(if (visited? current closed) ;if visited, skip and go to next state
			(a*-graph percept (car (cdr frontier)) energy (cdr frontier) closed)
    		(a*-graph percept (car (sort (uniqueappend (dropcurrent frontier current) (get-legalchildren current percept energy)) percept energy)) 
    			;next current is first element of sorted list of new frontier which is without current and with children
    			energy 
				(sort (uniqueappend (dropcurrent frontier current) (get-legalchildren current percept energy)) percept energy)
				;new frontier which is without current and with children
    			(cons current closed))))))



; (a*-graph-search (percept) 1000)
