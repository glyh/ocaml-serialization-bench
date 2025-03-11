module CrypRandom = Random
open Core
open Bin_prot.Std

module BinProtBench = Serializable.Bench (struct
  type t = string [@@deriving bin_io]

  let name = "string"
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
  type t = string [@@deriving yojson]

  let name = "string"
  let backend = "yojson"
  let serialize (v : t) = to_yojson v |> Yojson.Safe.to_string

  let deserialize (s : string) =
    match Yojson.Safe.from_string s |> of_yojson with
    | Ok v -> v
    | _ -> failwith "can't deserialize"
end)

module ProtobufBench = Serializable.Bench (struct
  type t = string

  let name = "string"
  let backend = "protobuf"

  let serialize (s : t) =
    let encoder = Pbrt.Encoder.create () in
    Message_pb.encode_pb_str { str = s } encoder;
    Pbrt.Encoder.to_string encoder

  let deserialize (s : string) =
    let decoder = Pbrt.Decoder.of_string s in
    let record = Message_pb.decode_pb_str decoder in
    record.str
end)

module CapnprotoBench = Serializable.Bench (struct
  module CapnpMessage = Message_cp.Make (Capnp.BytesMessage)

  type t = string

  let name = "string"
  let backend = "capnproto"

  let serialize (str : t) : string =
    let open CapnpMessage.Builder.Str in
    let rw = init_root () in
    values_set rw str |> ignore;
    let message = to_message rw in
    Capnp.Codecs.serialize ~compression:`None message

  let deserialize (s : string) : t =
    let open CapnpMessage.Builder.Str in
    let stream = Capnp.Codecs.FramedStream.of_string ~compression:`None s in
    let res = Capnp.Codecs.FramedStream.get_next_frame stream in
    match res with
    | Result.Ok msg -> of_message msg |> values_get
    | _ -> failwith "no frame extracted"
end)

module CapnprotoPackingBench = Serializable.Bench (struct
  module CapnpMessage = Message_cp.Make (Capnp.BytesMessage)

  type t = string

  let name = "string"
  let backend = "capnproto packing"

  let serialize (str : t) : string =
    let open CapnpMessage.Builder.Str in
    let rw = init_root () in
    values_set rw str |> ignore;
    let message = to_message rw in
    Capnp.Codecs.serialize ~compression:`Packing message

  let deserialize (s : string) : t =
    let open CapnpMessage.Reader.Str in
    let stream = Capnp.Codecs.FramedStream.of_string ~compression:`Packing s in
    let res = Capnp.Codecs.FramedStream.get_next_frame stream in
    match res with
    | Result.Ok msg -> of_message msg |> values_get
    | _ -> failwith "no frame extracted"
end)

let () =
  let len = 50000000 in
  let str = CrypRandom.string len in
  Printf.printf "Trying to test serialization on string of length %d\n" len;
  BinProtBench.bench_round str;
  YojsonBench.bench_round str;
  ProtobufBench.bench_round str;
  CapnprotoBench.bench_round str;
  CapnprotoPackingBench.bench_round str
