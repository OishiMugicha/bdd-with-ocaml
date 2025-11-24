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

end