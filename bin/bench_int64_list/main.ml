open Core
open Bin_prot.Std

let rand_int64_of_range (lower : int64) (upper : int64) =
  let open Int64 in
  lower + Random.int64 (upper - lower)

module BinProtBench = Serializable.Bench (struct
  type t = int64 list [@@deriving bin_io]

  let name = "int64 list"
  let backend = "bin_prot"

  let serialize (lst : t) : string =
    let sz = bin_size_t lst in
    let buf = Bin_prot.Common.create_buf sz in
    bin_write_t buf ~pos:0 lst |> ignore;
    Bigstring.to_string buf

  let deserialize (s : string) =
    let buf = Bigstring.of_string s in
    bin_read_t buf ~pos_ref:(ref 0)
end)

module YojsonBench = Serializable.Bench (struct
  type t = int64 list [@@deriving yojson]

  let name = "int64 list"
  let backend = "yojson"
  let serialize (v : t) = to_yojson v |> Yojson.Safe.to_string

  let deserialize (s : string) =
    match Yojson.Safe.from_string s |> of_yojson with
    | Ok v -> v
    | _ -> failwith "can't deserialize"
end)

module ProtobufBench = Serializable.Bench (struct
  type t = int64 list

  let name = "int64 list"
  let backend = "protobuf"

  let serialize (lst : t) =
    let encoder = Pbrt.Encoder.create () in
    Message_pb.encode_pb_int64_list { values = lst } encoder;
    Pbrt.Encoder.to_string encoder

  let deserialize (s : string) =
    let decoder = Pbrt.Decoder.of_string s in
    let record = Message_pb.decode_pb_int64_list decoder in
    record.values
end)

module CapnprotoBench = Serializable.Bench (struct
  module CapnpMessage = Message_cp.Make (Capnp.BytesMessage)

  type t = int64 list

  let name = "int64 list"
  let backend = "capnproto"

  let serialize (lst : t) : string =
    let open CapnpMessage.Builder.Int64List in
    let rw = init_root () in
    values_set_list rw lst |> ignore;
    let message = to_message rw in
    Capnp.Codecs.serialize ~compression:`None message

  let deserialize (s : string) : t =
    let open CapnpMessage.Reader.Int64List in
    let stream = Capnp.Codecs.FramedStream.of_string ~compression:`None s in
    let res = Capnp.Codecs.FramedStream.get_next_frame stream in
    match res with
    | Result.Ok msg -> of_message msg |> values_get |> Capnp.Array.to_list
    | _ -> failwith "no frame extracted"
end)

module CapnprotoPackingBench = Serializable.Bench (struct
  module CapnpMessage = Message_cp.Make (Capnp.BytesMessage)

  type t = int64 list

  let name = "int64 list"
  let backend = "capnproto packing"

  let serialize (lst : t) : string =
    let open CapnpMessage.Builder.Int64List in
    let rw = init_root () in
    values_set_list rw lst |> ignore;
    let message = to_message rw in
    Capnp.Codecs.serialize ~compression:`Packing message

  let deserialize (s : string) : t =
    let open CapnpMessage.Reader.Int64List in
    let stream = Capnp.Codecs.FramedStream.of_string ~compression:`Packing s in
    let res = Capnp.Codecs.FramedStream.get_next_frame stream in
    match res with
    | Result.Ok msg -> of_message msg |> values_get |> Capnp.Array.to_list
    | _ -> failwith "no frame extracted"
end)

let () =
  Random.init (Time_now.nanoseconds_since_unix_epoch () |> Int63.to_int_exn);
  let len = 50000000 in
  let min = -2100000000L in
  let max = 2100000000L in
  let lst = List.init len ~f:(fun _ -> rand_int64_of_range min max) in
  Printf.printf
    "Trying to test serialization on int64 list of length %d sampled from \
     [%Ld, %Ld)\n"
    len min max;
  BinProtBench.bench_round lst;
  YojsonBench.bench_round lst;
  ProtobufBench.bench_round lst;
  CapnprotoBench.bench_round lst;
  CapnprotoPackingBench.bench_round lst
