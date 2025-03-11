module CrypRandom = Random
open Core
open Bin_prot.Std

type merkle_tree = Leaf of int64 | Internal of int64 * merkle_tree array
[@@deriving bin_io, yojson]

module BinProtBench = Serializable.Bench (struct
  type t = merkle_tree

  let name = "merkle tree"
  let backend = "bin_prot"

  let serialize (lst : t) : string =
    let sz = bin_size_merkle_tree lst in
    let buf = Bin_prot.Common.create_buf sz in
    bin_write_merkle_tree buf ~pos:0 lst |> ignore;
    Bigstring.to_string buf

  let deserialize (s : string) =
    let buf = Bigstring.of_string s in
    bin_read_merkle_tree buf ~pos_ref:(ref 0)
end)

module YojsonBench = Serializable.Bench (struct
  type t = merkle_tree

  let name = "merkle tree"
  let backend = "yojson"
  let serialize (v : t) = merkle_tree_to_yojson v |> Yojson.Safe.to_string

  let deserialize (s : string) =
    match Yojson.Safe.from_string s |> merkle_tree_of_yojson with
    | Ok v -> v
    | _ -> failwith "can't deserialize"
end)

module ProtobufBench = Serializable.Bench (struct
  type t = merkle_tree

  let name = "merkle tree"
  let backend = "protobuf"

  let rec merkle_tree_to_pb t =
    match t with
    | Leaf hash -> Message_pb.{ hash; kind = Leaf }
    | Internal (hash, children) ->
        Message_pb.
          {
            hash;
            kind =
              Internal
                {
                  children =
                    Array.to_list children |> List.map ~f:merkle_tree_to_pb;
                };
          }

  let rec merkle_tree_of_pb t =
    let Message_pb.{ hash; kind } = t in
    match kind with
    | Leaf -> Leaf hash
    | Internal { children } ->
        Internal
          (hash, children |> List.map ~f:merkle_tree_of_pb |> Array.of_list)

  let serialize (tree : t) =
    let encoder = Pbrt.Encoder.create () in
    Message_pb.encode_pb_merkle_tree (tree |> merkle_tree_to_pb) encoder;
    Pbrt.Encoder.to_string encoder

  let deserialize (s : string) : t =
    let decoder = Pbrt.Decoder.of_string s in
    let record = Message_pb.decode_pb_merkle_tree decoder in
    record |> merkle_tree_of_pb
end)

module CapnprotoBench = Serializable.Bench (struct
  module CapnpMessage = Message_cp.Make (Capnp.BytesMessage)

  type t = merkle_tree

  let name = "string"
  let backend = "capnproto"

  open CapnpMessage.Builder

  let rec write_tree (tree : t) (result : MerkleTree.t) =
    let open MerkleTree in
    match tree with
    | Leaf hash ->
        hash_set result hash;
        leaf_set result
    | Internal (hash, children) ->
        hash_set result hash;
        let children_array = internal_init result (Array.length children) in
        Capnp.Array.iteri children_array ~f:(fun idx child ->
            write_tree children.(idx) child)

  let rec read_tree (n : MerkleTree.t) : t =
    match MerkleTree.get n with
    | Leaf -> Leaf (MerkleTree.hash_get n)
    | Internal children ->
        let children_array =
          Array.init (Capnp.Array.length children) ~f:(const (Leaf 0L))
        in
        Capnp.Array.iteri children ~f:(fun idx child ->
            children_array.(idx) <- read_tree child);
        Internal (MerkleTree.hash_get n, children_array)
    | _ -> failwith "can't deserialize merkle_tree with cp"

  let serialize (tree : t) : string =
    let open MerkleTree in
    let rw = init_root () in
    write_tree tree rw;
    let message = to_message rw in
    Capnp.Codecs.serialize ~compression:`None message

  let deserialize (s : string) : t =
    let open MerkleTree in
    let stream = Capnp.Codecs.FramedStream.of_string ~compression:`None s in
    let res = Capnp.Codecs.FramedStream.get_next_frame stream in
    match res with
    | Result.Ok msg -> of_message msg |> read_tree
    | _ -> failwith "no frame extracted"
end)

module CapnprotoPackingBench = Serializable.Bench (struct
  module CapnpMessage = Message_cp.Make (Capnp.BytesMessage)

  type t = merkle_tree

  let name = "string"
  let backend = "capnproto"

  open CapnpMessage.Builder

  let rec write_tree (tree : t) (result : MerkleTree.t) =
    let open MerkleTree in
    match tree with
    | Leaf hash ->
        hash_set result hash;
        leaf_set result
    | Internal (hash, children) ->
        hash_set result hash;
        let children_array = internal_init result (Array.length children) in
        Capnp.Array.iteri children_array ~f:(fun idx child ->
            write_tree children.(idx) child)

  let rec read_tree (n : MerkleTree.t) : t =
    match MerkleTree.get n with
    | Leaf -> Leaf (MerkleTree.hash_get n)
    | Internal children ->
        let children_array =
          Array.init (Capnp.Array.length children) ~f:(const (Leaf 0L))
        in
        Capnp.Array.iteri children ~f:(fun idx child ->
            children_array.(idx) <- read_tree child);
        Internal (MerkleTree.hash_get n, children_array)
    | _ -> failwith "can't deserialize merkle_tree with cp"

  let serialize (tree : t) : string =
    let open MerkleTree in
    let rw = init_root () in
    write_tree tree rw;
    let message = to_message rw in
    Capnp.Codecs.serialize ~compression:`Packing message

  let deserialize (s : string) : t =
    let open MerkleTree in
    let stream = Capnp.Codecs.FramedStream.of_string ~compression:`Packing s in
    let res = Capnp.Codecs.FramedStream.get_next_frame stream in
    match res with
    | Result.Ok msg -> of_message msg |> read_tree
    | _ -> failwith "no frame extracted"
end)

let rec generate_tree ~depth ~branch_max ~branch_min =
  let hash = CrypRandom.int64 () in
  if depth = 0 then Leaf hash
  else
    let num_leaves =
      branch_min + CrypRandom.int ~max:(branch_max - branch_min) ()
    in
    let children =
      Array.init num_leaves ~f:(fun _ ->
          generate_tree ~depth:(depth - 1) ~branch_min ~branch_max)
    in
    Internal (hash, children)

let () =
  let depth = 10 in
  let branch_max = 10 in
  let branch_min = 2 in
  let tree = generate_tree ~depth ~branch_max ~branch_min in
  Printf.printf
    "Trying to test serialization on merkle_tree of depth %d and branching \
     factor [%d, %d)\n"
    depth branch_min branch_max;
  BinProtBench.bench_round tree;
  YojsonBench.bench_round tree;
  ProtobufBench.bench_round tree;
  CapnprotoBench.bench_round tree;
  CapnprotoPackingBench.bench_round tree
