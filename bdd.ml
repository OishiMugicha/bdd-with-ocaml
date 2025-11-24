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

  

end