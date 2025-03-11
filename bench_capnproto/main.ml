open Core

let rand_int64_of_range (lower : int64) (upper : int64) =
  let open Int64 in
  lower + Random.int64 (upper - lower)

module CapnpMessage = Message.Make (Capnp.BytesMessage)

module type Capnprotable = sig
  type t

  val name : string
  val serialize : t -> string
  val deserialize : string -> t
end

module BenchCapnpro (C : Capnprotable) = struct
  let time_it label f =
    let start_time = Time_ns.now () in
    let result = f () in
    let end_time = Time_ns.now () in
    let duration_ms = Time_ns.diff end_time start_time |> Time_ns.Span.to_ms in
    Printf.printf "%s took %f sec\n" label (duration_ms /. 1000.);
    result

  let bench_serialize (v : C.t) =
    let label = Printf.sprintf "byte serializing %s" C.name in
    let result = time_it label (fun _ -> C.serialize v) in
    result

  let bench_deserialize (buf : string) =
    let label = Printf.sprintf "byte deserializing %s" C.name in
    let result = time_it label (fun _ -> C.deserialize buf) in
    result

  let bench_round (v : C.t) =
    let serialized = bench_serialize v in
    bench_deserialize serialized |> ignore
end

module Int64List = struct
  type t = int64 list

  let len = 50000000
  let min = -2147483648L
  let max = 2147483647L

  let name =
    Printf.sprintf
      "int64 list of len %d filled with element sampled from [%Ld, %Ld)" len min
      max

  let generate () : t = List.init len ~f:(fun _ -> rand_int64_of_range min max)

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
end

module Int64ListBench = BenchCapnpro (Int64List)

let () =
  Random.init (Time_now.nanoseconds_since_unix_epoch () |> Int63.to_int_exn);
  Int64ListBench.bench_round (Int64List.generate ())
