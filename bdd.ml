type node =
  | Zero
  | One
  | Node of int * node * node * (node option)

module Node = struct
  type t = node
  let compare = compare
end

module NodeSet = Set.Make(Node)

module BDD = struct

  type t = {
    unique_table : NodeSet.t;
    root : node;
  }

  let const b = match b with
    | true -> {unique_table = NodeSet.singleton(One); root = One}
    | false -> {unique_table = NodeSet.singleton(Zero); root = Zero}

  let var i =
    let root = Node (i, Zero, One, None) in
    let unique_table = NodeSet.of_list([Zero; One; root]) in
    {unique_table; root}
  
  let resolve : node -> node = fun u ->
    let get_distination v = match v with
      | Zero | One -> v
      | Node (_, _, _, aux) -> Option.value aux ~default: v
    in
    match u with
    | Zero | One -> u
    | Node (i, u0, u1, aux) -> Node ( i, get_distination u0, get_distination u1, aux)
  
  let reduce_by_r1 : node -> node = fun u ->
    match u with
    | Zero | One -> u
    | Node (i, u0, u1, _) ->
        if u0 = u1 then Node (i, u0, u1, Some u0) else u

end