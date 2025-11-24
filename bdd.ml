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
    n : int;
  }

  let const b = match b with
    | true -> {unique_table = NodeSet.singleton(One); n = 0}
    | false -> {unique_table = NodeSet.singleton(Zero); n = 0}

  let var i =
    let unique_table = NodeSet.of_list([Zero; One; Node (i, Zero, One, None)]) in
    {unique_table; n = 1}
  
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

  let reduce : t -> t = fun bst ->
    let rec loop : int -> NodeSet.t -> NodeSet.t = fun i ut ->
      if i = bst.n + 1 then ut else
      let ut' = NodeSet.map (fun u -> match u with
                  | Node (i, _, _, _) -> u |> resolve |> reduce_by_r1
                  | _ -> u) ut
      in loop (i + 1) ut'
    in
    { unique_table = loop 1 bst.unique_table; n = bst.n}

  module CacheKey = struct
    type t = node * node
    let compare = compare
  end

  module CacheMap = Map.Make(CacheKey)

  type cache = node CacheMap.t

  let empty_cache = CacheMap.empty

  let apply : (bool -> bool -> bool) -> t -> t -> t = fun op f g ->
    let cache = empty_cache in
    f

  let index : node -> int = fun u ->
    match u with
    | Zero | One -> 0
    | Node (i, _, _, _) -> i
  
  let top : t -> node = fun f ->
    NodeSet.find_first (fun u -> index u = f.n) f.unique_table
  
  let get_bool_opt : t -> bool option = fun f ->
    match top f with
    | Zero -> Some false
    | One -> Some true
    | _ -> None
  
  

end