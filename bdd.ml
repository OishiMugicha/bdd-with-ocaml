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


  let index : node -> int = fun u ->
    match u with
    | Zero | One -> 0
    | Node (i, _, _, _) -> i
  
  let top : t -> node = fun f ->
    NodeSet.find_first (fun u -> index u = f.n) f.unique_table
  
  let get_bool_opt : node -> bool option = fun u ->
    match u with
    | Zero -> Some false
    | One -> Some true
    | _ -> None
  
  let bool_to_node : bool -> node = fun b ->
    if b then One else Zero
  
  let apply : (bool -> bool -> bool) -> t -> t -> t = fun op f g ->
    let cache = ref CacheMap.empty in
    let ut = ref NodeSet.empty in
    let rec apply_inner : node -> node -> node = fun u v ->
      let const_with_const u v =
        let b = match (u, v) with
          | (Zero, Zero) -> op false false
          | (Zero, One) -> op false true
          | (One, Zero) -> op true false
          | (One, One) -> op true true
          | _ -> raise (Invalid_argument "")
        in
        let w = bool_to_node b in
        ut := NodeSet.add w !ut;
        cache := CacheMap.add (u, v) w !cache;
        w
      in
      let left_higher u v =
        match u with
        | Zero | One -> raise (Invalid_argument "")
        | Node (i, u0, u1, _) ->
            let w0 = apply_inner u0 v in
            let w1 = apply_inner u1 v in
            let w = if w0 = w1 then w0 else Node (i, w0, w1, None) in
            ut := NodeSet.add w !ut;
            cache := CacheMap.add (u, v) w !cache;
            w
      in
      let right_higher u v =
        match v with
        | Zero | One -> raise (Invalid_argument "")
        | Node (j, v0, v1, _) ->
            let w0 = apply_inner u v0 in
            let w1 = apply_inner u v0 in
            let w = if w0 = w1 then w0 else Node (j, w0, w1, None) in
            ut := NodeSet.add w !ut;
            cache := CacheMap.add (u, v) w !cache;
            w
      in
      u
    in
    f


end