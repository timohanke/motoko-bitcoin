import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import IterExt "mo:iterext";
import Binary "mo:encoding/Binary";
import SHA2 "mo:sha2";

module {
    func reverse<T>(a : [T]) : [T] {
        let len = a.size();
        Array.tabulate<T>(len, func(i) { a[(len-1)-i] })
    };

    func reverse_blob(b : Blob) : Blob {
        Blob.fromArray(reverse<Nat8>(Blob.toArray(b)))
    };

    public class Bits(data : Blob) {
        assert(data.size() == 4);
        public let raw = data;
        let bytes = Blob.toArray(data);
        let exp = Nat8.toNat(bytes[0]);
        let base = (Nat8.toNat(bytes[1])*256 + Nat8.toNat(bytes[2]))*256 + Nat8.toNat(bytes[3]);    
        public let target_as_nat : Nat = base * 2**(8*(exp-3));
        public let difficulty = 0xffff * 2**208 / target_as_nat;
        public let work = 2**256 / (target_as_nat + 1);

        public let target_as_blob = do {
            let target = Array.init<Nat8>(32, 0);
            target[32-exp] := bytes[1];
            target[32-exp+1] := bytes[2];
            target[32-exp+2] := bytes[3];            
            Blob.fromArrayMut(target)
        };
    };

    public type BlockHeaderSummary = { version : Nat32; hashPrevBlock : Blob; hashMerkleRoot : Blob; time : Nat32; bits : Blob; nonce : Nat32; target_nat : Nat; target_blob : Blob; difficulty : Nat; hash : Blob; meets_target : Bool };

    public class BlockHeader(data : Blob) {
        assert(data.size() == 80);
        // raw
        public let raw = data;

        let buf4 = IterExt.BlockBuffer<Nat8>(4);
        let buf32 = IterExt.BlockBuffer<Nat8>(32);   
        let bytes = data.vals();

        // version number
        assert(buf4.refill(bytes) == 4);
        public let version = Binary.LittleEndian.toNat32(buf4.toArray(#fwd));
        // previous block
        assert(buf32.refill(bytes) == 32);
        public let hashPrevBlock = Blob.fromArray(buf32.toArray(#bwd));
        // Merkle root
        assert(buf32.refill(bytes) == 32);
        public let hashMerkleRoot = Blob.fromArray(buf32.toArray(#bwd));
        // time
        assert(buf4.refill(bytes) == 4);
        public let time = Binary.LittleEndian.toNat32(buf4.toArray(#fwd));
        // bits (difficulty)
        assert(buf4.refill(bytes) == 4);
        public let bits : Bits = Bits(Blob.fromArray(buf4.toArray(#bwd)));
        // nonce
        assert(buf4.refill(bytes) == 4);
        public let nonce = Binary.LittleEndian.toNat32(buf4.toArray(#fwd));
        // hash
        public let hash : Blob = reverse_blob(SHA2.sha256_blob(SHA2.sha256_blob(data)));
        // target met?
        public let meets_target = Blob.less(hash, bits.target_as_blob);

        public let summary = { version = version ; hashPrevBlock = hashPrevBlock; hashMerkleRoot = hashMerkleRoot; time = time; bits = bits.raw; nonce = nonce; target_nat = bits.target_as_nat; target_blob = bits.target_as_blob; difficulty = bits.difficulty; hash = hash ; meets_target = meets_target };
    };

};
