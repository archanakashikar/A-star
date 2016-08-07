;-----------------------------------Heuritic function-------------------------

;-------------------------------heuristic function----------------------------------------------------

(define (heuristic-function current percept energy)
(H current (maxreward (get-goals percept)) (get-goals percept) percept energy))

(define (turns current goal);estimation of number of turns
(cond 	((and (equal? (dir current) 'N) (= (xcd current) (xcd goal)) (< (ycd current) (ycd goal))) 0)
		((and (equal? (dir current) 'N) (= (xcd current) (xcd goal)) (> (ycd current) (ycd goal))) 2)
		((and (equal? (dir current) 'E) (= (ycd current) (ycd goal)) (< (xcd current) (xcd goal))) 0)
		((and (equal? (dir current) 'E) (= (ycd current) (ycd goal)) (> (xcd current) (xcd goal))) 2)
		((and (equal? (dir current) 'S) (= (xcd current) (xcd goal)) (< (ycd current) (ycd goal))) 2)
		((and (equal? (dir current) 'S) (= (xcd current) (xcd goal)) (> (ycd current) (ycd goal))) 0)
		((and (equal? (dir current) 'W) (= (ycd current) (ycd goal)) (< (xcd current) (xcd goal))) 2)
		((and (equal? (dir current) 'W) (= (ycd current) (ycd goal)) (> (xcd current) (xcd goal))) 0)
		(else 1)))


(define (factor current goal)
(cond 	((and (= (xcd current) (xcd goal)) (= (abs (- (ycd current) (ycd goal))) 1)) 10) ;when the current is 1 cell away from goal, estimated cost
		((and (= (xcd current) (xcd goal)) (= (abs (- (ycd current) (ycd goal))) 2)) 7.5); when the current 2 cells away from the goal, estimated cost
		((and (= (xcd current) (xcd goal)) (= (abs (- (ycd current) (ycd goal))) 3)) 6) ;when current is 3 cells away from the goal
		((and (= (xcd current) (xcd goal)) (= (abs (- (ycd current) (ycd goal))) 4)) 7) ;when current is 4 cells away from the goal
		((and (= (xcd current) (xcd goal)) (= (abs (- (ycd current) (ycd goal))) 5)) 6.6)
		((and (= (ycd current) (ycd goal)) (= (abs (- (xcd current) (xcd goal))) 2)) 7.5)
		((and (= (ycd current) (ycd goal)) (= (abs (- (xcd current) (xcd goal))) 3)) 6)
		((and (= (xcd current) (xcd goal)) (= (abs (- (ycd current) (ycd goal))) 4)) 7)
		((and (= (xcd current) (xcd goal)) (= (abs (- (ycd current) (ycd goal))) 5)) 6.6)
		(else 9)))

(define (goalpoints current maxre goalre goal energy) ; addition to hueristic value based on energy state and goal rewards
(let ((Hv (+ (* (factor current goal) (+ (abs (- (ycd current) (ycd goal))) (abs (- (xcd current) (xcd goal))))) 
			(* 5 (turns current goal)))))
	(if (< (- energy (nth-item 3 current)) Hv) 
		(+ maxre (- Hv (- energy (nth-item 3 current))))
		(- maxre goalre))))

(define (H current maxre goals percept energy)
;	(display goals)
(cond 	((goal? percept current) 0) ;if only 1 goal
		((null? (cdr goals)) 
			(+ (goalpoints current maxre (goalreward (car goals) percept) (car goals) energy) 
				(* (factor current (car goals)) (+ (abs (- (ycd current) (ycd (car goals)))) (abs (- (xcd current) (xcd (car goals)))))) 
				(* 5 (turns current (car goals)))))
		((= (length goals) 2) ;if only 2 goals
			(min 
			(+ (goalpoints current maxre (goalreward (car goals) percept) (car goals) energy) ;points added based on reward and energy
				(* (factor current (car goals)) (+ (abs (- (ycd current) (ycd (car goals)))) (abs (- (xcd current) (xcd (car goals))))));distance from the goal
				(* 5 (turns current (car goals)))) ;number of turns to reach goal
			(+ (goalpoints current maxre (goalreward (cadr goals) percept) (cadr goals) energy)  
				(* (factor current (cadr goals)) (+ (abs (- (ycd current) (ycd (cadr goals)))) (abs (- (xcd current) (xcd (cadr goals))))))
				(* 5 (turns current (cadr goals))))))
		(else (min ;if more than 2 goals
			(+ (goalpoints current maxre (goalreward (car goals) percept) (car goals) energy)  
				(* (factor current (car goals)) (+ (abs (- (ycd current) (ycd (car goals)))) (abs (- (xcd current) (xcd (car goals))))))
				(* 5 (turns current (car goals))))
			(H current maxre (cdr goals) percept energy)))))

(define (a*val current percept)
(+ (heuristic-function current percept) (nth-item 3 current)))

(define (hval current goal) (+ (* (factor current goal) (+ (abs (- (ycd current) (ycd goal))) (abs (- (xcd current) (xcd goal))))) 
			(* 5 (turns current goal))))