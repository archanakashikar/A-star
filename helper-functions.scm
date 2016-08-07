;---------------------------HELPER FUNCTIONS----------------------------------------------

;--------------------helpers-----------------------

(define (rni pos alist elem) ;function to replace nth item 
(if (= pos 0) (cons elem (cdr alist)) ;if pos is 0 is the condition to break recursion
	(cons (car alist) (rni (- pos 1) (cdr alist) elem)))) ;pos is reduced by one each time and tail of the list is passed

(define (nth-item n alist) 
   (if (= n 0) (car alist) (nth-item (- n 1) (cdr alist)))) ;n is reduced by 1 each time and tail is passed

;---------------state variables-----------------------
(define (get-location x y percept) ;function to get the information of percept at a particular x and y coord
(if (or (< x 0) (> x 9)) '() ; if off bound values are asked for, return empty list
	(if (or (< y 0) (> y 9)) '()
(nth-item x (nth-item (- 9 y) percept))))) ;nth-item of (9-nth) sublist 

(define (xcd current) (nth-item 0 current)) ;to get x coord and y coord from a state
(define (ycd current) (nth-item 1 current))
(define (dir current) (nth-item 2 current))
(define (cost current) (nth-item 3 current)); (x y dir cost "manuever to reach this state")

;-------------------Goals--------------------------------

(define (get-goals percept) ;returns a list of goals from the percept
(goalsearch percept 0 0 '()))

(define (goalsearch percept x y goallist) ; iterative function to search row by row
(if (> y 9) (append '() goallist)
(goalsearch percept x (+ 1 y) (searchrow percept x y goallist))))

(define (searchrow percept x y goallist) ;search each row for goals and creates a list of goals
(if (> x 9) (append '() goallist)
(if (or (equal? (list (nth-item x (nth-item y percept))) '(empty)) (equal? (list (nth-item x (nth-item y percept))) '(barrier)))
	(searchrow percept (+ 1 x) y goallist)
	(searchrow percept (+ 1 x) y (append goallist (list (list x (- 9 y) (nth-item 1 (nth-item x (nth-item y percept))))))))))

(define (gx n goals) (nth-item 0 (nth-item (- n 1) goals))) ;x coord of a goal of a percept, goals can be got from (get-goals percept)
(define (gy n goals) (nth-item 1 (nth-item (- n 1) goals))) ;y coord of a goal of a percept

(define (goalreward goalstate percept) 
	(if (goal? percept goalstate)
		(nth-item 1 (nth-item (nth-item 0 goalstate) (nth-item (- 9 (nth-item 1 goalstate)) percept)))
		0 ))

(define (maxreward goals) ;maximum reward in a percept is returned - written using find-biggest
(if (null? goals) 0
  	(if (null? (cdr goals)) (nth-item 2 (car goals))
		(if (> (nth-item 2 (car goals)) (nth-item 2 (car (cdr goals))))
		(maxreward (cons (car goals) (cdr (cdr goals))))
			(maxreward (cdr goals))))))



(define (goal? percept current) ; to check if a cell is a goal, return #t or #f
(if (or (equal? (list (nth-item (nth-item 0 current) (nth-item (- 9 (nth-item 1 current)) percept))) '(barrier))
		(equal? (list (nth-item (nth-item 0 current) (nth-item (- 9 (nth-item 1 current)) percept))) '(empty))) #f ;if a cell is either empty or barrier, not a goal
		(if (equal? (list (nth-item 0 (nth-item (nth-item 0 current) (nth-item (- 9 (nth-item 1 current)) percept)))) '(goal)) #t #f))) 
		;if not empty or barrier, it must be a goal cell. Check if first element of that has "goal"

;------------------------all children(valid/invalid)----------------------------------

(define (get-move current newmove)
	(append (nth-item 4 current) newmove))

(define (get-children current) ; when a state is passed, this return all possible children including barriers and out of bound
	(cond ((equal? (nth-item 2 current) 'N)
		(cons (rni 4 (rni 3 (rni 1 current (+ 1 (ycd current))) (+ 10 (nth-item 3 current))) (get-move current '("MOVE-1"))) ;children are generated by appropriately replacing the state variables
			(cons (rni 4 (rni 3 (rni 1 current (+ 2 (ycd current))) (+ 15 (nth-item 3 current))) (get-move current '("MOVE-2")))
				(cons (rni 4 (rni 3 (rni 1 current (+ 3 (ycd current))) (+ 18 (nth-item 3 current))) (get-move current '("MOVE-3")))
					(cons (rni 4 (rni 3 (rni 2 current 'E) (+ 5 (nth-item 3 current))) (get-move current '("TURN-RIGHT")))
						(list (rni 4 (rni 3 (rni 2 current 'W) (+ 5 (nth-item 3 current))) (get-move current '("TURN-LEFT"))))))))) 
		((equal? (nth-item 2 current) 'E)
		(cons (rni 4 (rni 3 (rni 0 current (+ 1 (xcd current))) (+ 10 (nth-item 3 current))) (get-move current '("MOVE-1"))); increase xcd by 1, increase cost by 10
			(cons (rni 4 (rni 3 (rni 0 current (+ 2 (xcd current))) (+ 15 (nth-item 3 current))) (get-move current '("MOVE-2"))) ;increase xcd by 2, increase cost by 15
				(cons (rni 4 (rni 3 (rni 0 current (+ 3 (xcd current))) (+ 18 (nth-item 3 current))) (get-move current '("MOVE-3"))) ;increase xcd by 3, increase cost by 18
					(cons (rni 4 (rni 3 (rni 2 current 'S) (+ 5 (nth-item 3 current))) (get-move current '("TURN-RIGHT"))) ;change direction and increase cost by 5
						(list (rni 4 (rni 3 (rni 2 current 'N) (+ 5 (nth-item 3 current))) (get-move current '("TURN-LEFT"))))))))) ;change direction and change cost by 5
		((equal? (nth-item 2 current) 'S)
		(cons (rni 4 (rni 3 (rni 1 current (- (ycd current) 1)) (+ 10 (nth-item 3 current))) (get-move current '("MOVE-1"))) ;increase ycd by 1, increase cost by 10
			(cons (rni 4 (rni 3 (rni 1 current (- (ycd current) 2)) (+ 15 (nth-item 3 current))) (get-move current '("MOVE-2")));increase ycd by 2, increase cost by 15
				(cons (rni 4 (rni 3 (rni 1 current (- (ycd current) 3)) (+ 18 (nth-item 3 current))) (get-move current '("MOVE-3")));increase ycd by 3, increase cost by 18
					(cons (rni 4 (rni 3 (rni 2 current 'W) (+ 5 (nth-item 3 current))) (get-move current '("TURN-RIGHT")));change direction and increase cost by 5
						(list (rni 4 (rni 3 (rni 2 current 'E) (+ 5 (nth-item 3 current))) (get-move current '("TURN-LEFT")))))))));change direction and change cost by 5
		((equal? (nth-item 2 current) 'W)
		(cons (rni 4 (rni 3 (rni 0 current (- (xcd current) 1)) (+ 10 (nth-item 3 current))) (get-move current '("MOVE-1")))
			(cons (rni 4 (rni 3 (rni 0 current (- (xcd current) 2)) (+ 15 (nth-item 3 current))) (get-move current '("MOVE-2")))
				(cons (rni 4 (rni 3 (rni 0 current (- (xcd current) 3)) (+ 18 (nth-item 3 current))) (get-move current '("MOVE-3")))
					(cons (rni 4 (rni 3 (rni 2 current 'N) (+ 5 (nth-item 3 current))) (get-move current '("TURN-RIGHT")))
						(list (rni 4 (rni 3 (rni 2 current 'S) (+ 5 (nth-item 3 current))) (get-move current '("TURN-LEFT")))))))))))

;------------------------legal children---------------------------------------------------------

;--------------------------illegal?--------------------------------------


(define (illegal? percept child children) ;function to check legality of child
(if (or (< (xcd child) 0) (> (xcd child) 9) (< (ycd child) 0) (> (ycd child) 9) ;checks if x coord and y coord are out of bounds
    		(equal? (list (nth-item (xcd child) (nth-item (- 9 (ycd child)) percept))) '(barrier))) #t ;checks is a state is barrier location
		(if (equal? (nth-item 2 children) child) ;when MOVE-1 or MOVE-2 are illegal, MOVE-3 cannot legal
			(if (or (illegal? percept (nth-item 0 children) children) (illegal? percept (nth-item 1 children) children) 
					(goal? percept (nth-item 0 children)) (goal? percept (nth-item 1 children))) #t #f)
				(if (equal? (nth-item 1 children) child) 
					(if (or (illegal? percept (nth-item 0 children) children) (goal? percept (nth-item 0 children))) #t #f) #f))));


;----------get all legal children--------------------------
(define (legalchildren children percept allchildren) ;returns are legal children
(if (null? children) ;if null, return empty list(recursion terminator)
    '()
    (if (illegal?  percept (car children) allchildren) ;for every child,ie, head of a list, check if it is legal
    (legalchildren (cdr children) percept allchildren) ;if illegal, discard head and send tail into the function
    	(cons (car children) (legalchildren (cdr children) percept allchildren))))) ; if head of list legal, add to front and check tail 

;-------adding goal costs to goal cells----------------------


(define (goalcost percept children energy)
;(let (mr (maxreward (get-goals percept))); this fucntion adds cost to those goals which are lower than maximum reward
(if (null? children) '()
(if (null? (cdr children)) 
	(if (goal? percept (car children)) 
		(list (rni 3 (car children) (+ (- (maxreward (get-goals percept)) (goalreward (car children) percept)) 
										(nth-item 3 (car children))))) ;add (max reward - this goal reward) to cost
			(list (car children)))
	(if (goal? percept (car children)) 
		(append (list (rni 3 (car children) (+ (- (maxreward (get-goals percept)) (goalreward (car children) percept)) 
												(nth-item 3 (car children))))) 
				(goalcost percept (cdr children) energy))
			(append (list (car children)) (goalcost percept (cdr children) energy))))))



;--------get legal children(simplified function)-------------------------------------

(define (get-legalchildren current percept energy) ;legal children with goal costs
	(goalcost percept (legalchildren (get-children current) percept (get-children current)) energy)) ;corrected; changed for test- add goalcost




;----------------------------Sorting based on (cost + heuristic)-----------------------------------------


(define (odd alist)
	(if (null? alist) '()
		(if (null? (cdr alist)) (list (car alist))
			(cons (car alist) (odd (cdr (cdr alist))))))) ;this way first and alternate cells are selected
(define (even alist)
	(if (null? alist) '()
		(if (null? (cdr alist)) '()
			(cons (car (cdr alist)) (even (cdr (cdr alist)))))));this way second and alternate cells are selected

(define (split alist); splits into sets of odd and even cells
	(cons (odd alist) (cons (even alist) `())))


(define (merge alist blist percept energy)
	(if (null? alist) blist
		(if (null? blist) alist
			(if (< (+ (heuristic-function (car alist) percept energy) (nth-item 3 (car alist))) 
				(+ (heuristic-function (car blist) percept energy) (nth-item 3 (car blist)))) ;sorting is done based of H+C
				(cons (car alist) (merge (cdr alist) blist percept energy)) ;if alist < blist, (alist + blist)
				(cons (car blist) (merge (cdr blist) alist percept energy)))))) ;if (blist < alist), (alist + blist)

(define (sort children percept energy) ; sort is done using merge sort. list is aplit into 2 and each piece is sorted and this goes on till, only 2 are remaining
	(if (null? children) children
		(if (null? (cdr children)) children
			(merge (sort (car (split children)) percept energy) (sort (cadr (split children)) percept energy) percept energy))))

;---------------helpers-------------------

(define (dropcurrent frontier current); this function drops the current state from current frontier, for the sake of next frontier and next current
(if (null? frontier) '()
	(if (equal? (car frontier) current) ;check if head of frontier is same as current 
		(dropcurrent (cdr frontier) current) ;if yes, discard head and check for tail
    		(cons (car frontier) (dropcurrent (cdr frontier) current))))); if no, (head + check tail)

(define (path alist) ; get the path from the resultant closed list
(if (null? (cdr alist)) (list (nth-item 4 (car alist))) 
	(append (list (nth-item 4 (car alist))) (path (cdr alist)))))

(define (belongs? child children) ;to check if child belongs to that set of children
(if (null? children) #f ;if no children, it cannot belong
	(if (and (and (equal? (nth-item 2 (car children)) (nth-item 2 child))
			(and (= (xcd (car children)) (xcd child)) (= (ycd (car children)) (ycd child))))
			(equal? (nth-item 4 (car children)) (nth-item 4 child))) #t ; if xcd, ycd, direction and maneuver info are same, then it is belong to that children set
			(belongs? child (cdr children))))) ;else check for tail part
 

(define (similar? current closed) ;to check if there is a similar state in frontier
(if (null? closed) #f ;if closed is empty, curent cannot visit it
	(if (and (equal? (dir (car closed)) (dir current))
			(and (= (xcd (car closed)) (xcd current)) (= (ycd (car closed)) (ycd current))))
			 #t ; if xcd, ycd and direction are same, then it is visited
			(similar? current (cdr closed)))))

(define (dropsimilar frontier current); this function drops the similar state from current frontier, based on cost associated with each
(if (null? frontier) '()
	(if (and (and (= (xcd (car frontier)) (xcd current)) (= (ycd (car frontier)) (ycd current))) (equal? (dir (car frontier)) (dir current))) ;check if head of frontier is same as current 
		(cdr frontier) ;if yes, discard head and check for tail
    		(cons (car frontier) (dropsimilar (cdr frontier) current))))); if no, (head + check tail)



(define (costinFrontier frontier current) ;to check the cost a state in frontier, which is similar to current state
(if (and (equal? (dir (car frontier)) (dir current))
	(and (= (xcd (car frontier)) (xcd current)) (= (ycd (car frontier)) (ycd current))))
	(cost (car frontier)) ; if xcd, ycd and direction are same, then return cost
	(costinFrontier (cdr frontier) current))) ;else check further


(define (uniqueappend frontier children); this is to append new current children to frontier while checking to see if any similar state with higher cost exists in frontier
(if (null? children) 
	(append frontier '())
	(if (null? (cdr children))
		(if (similar? (car children) frontier) ;if a similar cell is already in frontier
			(if (<= (costinFrontier frontier (car children)) (cost (car children))) (append frontier '()) ;and if its cost is not more than current state, retain the one in frontier
				(append (dropsimilar frontier (car children)) (list(car children)))) ;if cost in frontier is more, drop that state from frontier and add the current state
			(append frontier (list(car children))))
		(if (similar? (car children) frontier) ;same as above, but recursively
			(if (<= (costinFrontier frontier (car children)) (cost (car children))) (uniqueappend frontier (cdr children))
				(uniqueappend (append (dropsimilar frontier (car children)) (list (car children))) (cdr children)))
			(uniqueappend (append frontier (list (car children))) (cdr children))))))
