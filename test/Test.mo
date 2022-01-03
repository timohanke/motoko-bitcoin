import Header "../src/Header";
import Hex "mo:encoding/Hex";
import Blob "mo:base/Blob";

func blob_from_hex(hex_string : Text) : Blob {
    Blob.fromArray(switch (Hex.decode(hex_string)) {
        case (#ok(arr)) { arr };
        case (#err(e)) { [] }
    })
};

let raw_genesis_header = blob_from_hex("0100000000000000000000000000000000000000000000000000000000000000000000003BA3EDFD7A7B12B27AC72C3E67768F617FC81BC3888A51323A9FB8AA4B1E5E4A29AB5F49FFFF001D1DAC2B7C");

let g = Header.BlockHeader(raw_genesis_header);

assert(g.version == 1);
assert(g.hashPrevBlock == blob_from_hex("0000000000000000000000000000000000000000000000000000000000000000"));
assert(g.hashMerkleRoot == blob_from_hex("4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b"));
assert(g.time == 1231006505);
assert(g.bits.raw == blob_from_hex("1d00ffff"));
assert(g.bits.target_as_nat == 26959535291011309493156476344723991336010898738574164086137773096960);
assert(g.bits.target_as_blob == blob_from_hex("00000000ffff0000000000000000000000000000000000000000000000000000"));
assert(g.bits.difficulty == 1);
assert(g.bits.work == 4295032833);
assert(g.nonce == 2083236893);
