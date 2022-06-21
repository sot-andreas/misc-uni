#!/usr/bin/env python3

import itertools


global nodes_created
global nodes_visited


# ====================================================================
# Tree
# ====================================================================

class TreeNode:
    def __init__(self, parent, state, action):
        self.parent = parent
        self.state = state
        self.action = action
        self.t_cost = 0 if parent is None else parent.t_cost + action.cost
        self.depth = 0 if parent is None else parent.depth + 1

        global nodes_created
        nodes_created += 1


def tree_search(problem, queuing_fun):
    visited = set()
    fringe = [TreeNode(None, problem.start, None)]
    while True:
        if not fringe:
            return None
        node = fringe.pop(0)

        global nodes_visited
        nodes_visited += 1

        if problem.is_goal(node.state):
            return node
        fringe = queuing_fun(fringe, expand(problem, node, visited))


def expand(problem, node, visited):
    acc = []
    for action, result in problem.successors(node.state):
        if result in visited:
            continue
        visited.add(result)
        acc.append(TreeNode(node, result, action))
    return acc


# ====================================================================
# Breadth-first Search
# ====================================================================

def breadth_first_search(problem):
    return tree_search(problem, breadth_first_search_queuing_fun)


def breadth_first_search_queuing_fun(fringe, successors):
    fringe.extend(successors)
    return fringe


# ====================================================================
# Uniform-cost Search
# ====================================================================

def uniform_cost_search(problem):
    return tree_search(problem, uniform_cost_search_queuing_fun)


def uniform_cost_search_queuing_fun(fringe, successors):
    successors = sorted(successors, key=lambda n: n.t_cost)
    fringe.extend(successors)
    return fringe


# ====================================================================
# Iterative-deepening Search
# ====================================================================

def iterative_deepening_search(problem):
    root = TreeNode(None, problem.start, None)
    for depth in itertools.count(start=0):  # From 0 to infinity loop
        found, remaining = depth_limited_search(problem, root, depth)
        if found:
            return found
        if not remaining:
            return None


def depth_limited_search(problem, node, depth):
    if depth == 0:
        global nodes_visited
        nodes_visited += 1

        if problem.is_goal(node.state):
            return node, True
        return None, True
    else:
        any_remaining = False
        for child in expand_dls(problem, node):
            found, remaining = depth_limited_search(problem, child, depth - 1)
            if found is not None:
                return found, True
            if remaining:
                any_remaining = True
        return None, any_remaining


def expand_dls(problem, node):
    acc = []
    for action, result in problem.successors(node.state):
        acc.append(TreeNode(node, result, action))
    return acc


# ====================================================================
# Best-first Search
# ====================================================================

def best_first_search(problem, eval_fun):
    queuing_fun = lambda x, y: best_first_search_queuing_fun(eval_fun, x, y)
    return tree_search(problem, queuing_fun)


def best_first_search_queuing_fun(eval_fun, fringe, successors):
    fringe.extend(successors)
    fringe = sorted(fringe, key=eval_fun)
    return fringe


# ====================================================================
# A* search algorithm
# ====================================================================

def a_star(problem, g, h):
    eval_fun = lambda x: g(x) + h(x)
    return best_first_search(problem, eval_fun)


# ====================================================================
# Problem
# ====================================================================

class State:
    def __init__(self, people, torch):
        self.people = tuple(people)
        self.torch = torch

    def __eq__(self, other):
        return isinstance(other, State) \
            and (self.torch == other.torch) \
            and (set(self.people) == set(other.people))

    def __hash__(self):
        return hash((self.people, self.torch))


class Person:
    def __init__(self, name, cost):
        self.name = name
        self.cost = cost


class ActionPass:
    """This class represents the action of two people crossing the bridge."""
    def __init__(self, p1, p2):
        self.person1 = p1
        self.person2 = p2
        self.cost = p1.cost if p1.cost > p2.cost else p2.cost

    def __str__(self):
        return f"Ο {self.person1.name} και ο {self.person2.name}" \
            + f" διασχίζουν την γέφυρα σε {self.cost}" \
            + (" λεπτό." if self.cost == 1 else " λεπτά.")


class ActionReturn:
    """This class represents that action of a person returning at the start."""
    def __init__(self, person):
        self.person = person
        self.cost = person.cost

    def __str__(self):
        return f"Ο {self.person.name} γυρίζει πίσω σε {self.cost}" \
            + (" λεπτό." if self.cost == 1 else " λεπτά.")


class BridgeTorchProblem:
    """A representation of the bridge torch problem

    The state passed in the provided methods must be of the starting
    side of the bridge.
    """

    def __init__(self, people):
        self.people = tuple(people)  # A tuple of the people involved
        self.start = State(people, True)  # The initial state
        self.goal = State((), False)  # The goal state

    def is_goal(self, state: State) -> bool:
        return state == self.goal

    def people_passed(self, state):
        """Returns the people that are on the ending side of the bridge."""
        return filter(lambda x: x not in state.people,
                      self.people)

    def successors(self, state):
        """Returns a list of all the successor states from the given state."""
        accumulator = []
        if state.torch:  # If the torch is at the start of the bridge
            for i, j in itertools.combinations(state.people, 2):
                people = list(state.people)
                people.remove(i)  # Move i to the other side
                people.remove(j)  # Move j to the other side
                action = ActionPass(i, j)
                state0 = State(people, False)  # The torch is at the end
                accumulator.append((action, state0))
        else:
            for i in self.people_passed(state):
                people = list(state.people)
                people.append(i)  # Move i to the other side
                action = ActionReturn(i)
                state0 = State(people, True)  # The torch is at the beginning
                accumulator.append((action, state0))
        return accumulator


# ====================================================================
# Bridge torch problem heurestics
# ====================================================================
def heurestic1(node):
    """Heurestic based on the assumption that the torch is not needed
    and that the bridge has no limit on the amount of people that can
    cross it.

    Creates and visits less nodes than heurestic2, but the Greedy
    Best-first search algorithm is not as accurate.
    """
    # Initialize `cost' to the lowest possible cost.
    # This is the case where there are no more people to pass. (Goal state)
    cost = 0

    # They can all pass the bridge at the speed of the slowest person
    for i in node.state.people:
        if i.cost > cost:
            cost = i.cost
    return cost


def heurestic2(problem, node):
    """Heurestic based on the assumption that the torch is needed and that
    the bridge has no limit on the amount of people that can cross it.

    The Greedy Best-first search algorithm is more accurate, but it
    also creates and visits more nodes.
    """
    # Initialize `cost' to the lowest possible cost.
    # This is the case where there are no more people to pass. (Goal state)
    cost = 0

    # If the torch is at the beginning.
    if node.state.torch:
        # Assuming no limit on how many can cross the bridge,
        # they can all pass at the speed of the slowest person.
        for i in node.state.people:
            if i.cost > cost:
                cost = i.cost
    else:
        people = problem.people_passed(node.state)
        # Initialize to the cost of a person form the set, if any.
        for i in people:
            cost = i.cost
            break

        # If there are people with the torch at the end, the fastest shall
        # return to the beginning.
        for i in people:
             if i.cost < cost:
                cost = i.cost

    return cost


# ====================================================================
# Main
# ====================================================================

def user_in_people() -> int:
    while True:
        n = input("Αριθμός ανθρώπων: ")
        try:
            n = int(n)
            if n < 2:
                print("Παρακαλώ εισάγετε > 1 ανθρώπους.")
            else:
                return n
        except ValueError:
            print(f"Mη αποδεκτή είσοδος: ``{n}''."
                  "Παρακαλώ εισάγετε έναν ακέραιο θετικό αριθμό.")


def user_in_costs(n: int) -> list:
    acc = []
    i = 1
    while i <= n:
        cost = input(f"Ταχύτητα {i}ου (σε λεπτά): ")
        try:
            name = f"A{i}"
            acc.append(Person(name, int(cost)))
            i += 1
        except ValueError:
            print(f"Mη αποδεκτή είσοδος: ``{cost}''."
                  "Παρακαλώ εισάγετε έναν ακέραιο θετικό αριθμό.")
    return acc


if __name__ == "__main__":
    n_people = user_in_people()
    people = user_in_costs(n_people)

    problem = BridgeTorchProblem(people)

    # Curry the heurestic2 to use one argument
    h2 = lambda n: heurestic2(problem, n)

    algorithms = {
        # "Breadth-first": lambda: breadth_first_search(problem),
        "Uniform-cost": lambda: uniform_cost_search(problem),
        "Best-first": lambda: best_first_search(problem, h2),
        "A*": lambda: a_star(problem, lambda n: n.t_cost, heurestic1),
        "Iterative-deepening": lambda: iterative_deepening_search(problem)
    }

    print("")
    for name, fun in algorithms.items():
        print(f"{name} search algorithm:")

        # Reset the counters
        nodes_created = 0
        nodes_visited = 0

        # Aply the algorithm's function
        ret = fun()
        if not ret:
            print("\nΔεν βρέθηκε αποτέλεσμα.")
            continue

        rpl = []
        node = ret
        while True:
            if node.parent is None:
                break
            rpl.insert(0, node.action)
            node = node.parent

        for i in rpl:
            print(i)

        print(f"\nΣυνολικός χρόνος: {ret.t_cost} λεπτά")
        print(f"Πλήθος κόμβων που δημιούργησε: {nodes_created}")
        print(f"Πλήθος κόμβων που επισκέφθηκε: {nodes_visited}")
        print("-----------------------------------------------")
