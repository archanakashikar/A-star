# A-star


*Implementation of a-star-tree-search, a-star-graph-search algorithms for optimal path-finding in Scheme*
An agent is looking for a goal with the best reward in a grid(observable environment) populated with barriers,
empty spaces and goals. The agent starts with an initial energy. As it moves through the grid,
it loses energy as shown below-
3 steps costs 18 points
2 steps costs 15 points
1 step costs 10 points
turning left or right costs 5 points

This algorithm helps the agent find an optimal path to the best rewarding goal which is affordable with 
the available energy. 


*HEURISTIC FUNCTION*

Estimation of cost required to reach a goal from current location.

For the purpose of both the searches, following heuristic function is used

Parameters used for Heuristic function:
Goal summary:
((x coord1, y coord1, reward1) (x coord2, y coord2, reward2)….)

current location:
(x , y,  direction,  cost-so-far, (moves)) 

*Energy*:
Initial Energy 

H = min (H1, H2, H3…Hn), 

Where,

Hn = 	goalpoints 
+ factor *{(# horizontal steps from goal 1) + (# horizontal steps from goal 1)} 
+ turns 

*goalpoints*: This is penalty added to increase heuristic value wrt a goal, based on energy available to reach that goal and how less is the reward at that location from the maximum reward.

(if (energy –cost-so-far) <Heuristic-value) ;not enough energy
(Maxreward + (Heuristic-value + (cost-so-far) – energy) ;penalty is increased by its reward  and deficiency in energy
else 
(Maxreward – goalreward) ;penalty for having less reward than maximum reward

*Factor*: This is the multiplying factor to the distance from goal
If 1 cell away from goal, factor = 10
If 1 cell away from goal, factor = 7.5
If 1 cell away from goal, factor = 6
If 1 cell away from goal, factor = 7
Else, average factor = 9

*Turns*: Estimation of number of turns to reach goal
If in the same row or column as goal, turns = 0
If in different row and column, turns = 1




