import { NativeModules } from 'react-native';

function arrayBufferToHexString(buffer: ArrayBuffer) {
  return Array.prototype.map
    .call(new Uint8Array(buffer), x => `00${x.toString(16)}`.slice(-2))
    .join('');
}

function hexStringToByteArray(hexString: string): ArrayBuffer {
  const typedArray = new Uint8Array(
    (hexString.match(/[\da-f]{2}/gi) || []).map((h: string) => {
      return parseInt(h, 16);
    }),
  );
  return typedArray.buffer;
}

function toByteArray(data: any) {
  if (data.buffer) {
    return new Uint8Array(data.buffer, data.byteOffset, data.byteLength);
  }
  return new Uint8Array(data);
}

class RandomPool {
  pool: number[] = [];

  pending: number = 0;

  addEntropy(entropy: ArrayBuffer) {
    const buffer = new Uint8Array(entropy);
    Array.prototype.forEach.call(buffer, x => {
      this.pool.push(x);
    });
    this.pending -= buffer.length;
    if (this.pending < 0) {
      throw new Error('Something went wrong');
    }
  }

  getRandomByte(): number {
    const randomByte = this.pool.shift();
    if (this.pool.length + this.pending < 1024 * 48) {
      this.fetchEntropy(1024 * 64);
    }

    if (typeof randomByte === 'undefined') {
      throw new Error("We've run out of entropy, sorry.");
    }

    return randomByte;
  }

  async fetchEntropy(size: number) {
    this.pending += size;
    const randomString = await NativeModules.WindowCrypto.generateEntropy(size);
    const randomBuffer = hexStringToByteArray(randomString);
    this.addEntropy(randomBuffer);
  }
}

const randomPool = new RandomPool();

interface CryptoKey {
  extractable: boolean;
  type?: 'public' | 'private';
  usages: string[];
  id: number;
}

interface Algorithm {
  name: string;
  namedCurve: string;
}

type TypedArray = ArrayBuffer | Uint8Array | Uint16Array | Uint32Array;
export const crypto = {
  getRandomValues(a: TypedArray) {
    const view = toByteArray(a);
    const len = view.length;

    if (len > 65536) {
      throw new Error('crypto.getRandomValues: Quota exceeded');
    }

    // const rnd = forge.random.getBytesSync(len);
    for (let i = 0; i < len; i += 1) {
      const x = randomPool.getRandomByte();
      view[i] = x;
    }
    return a;
  },
  subtle: {
    async digest(
      algorithm: string | { name: string },
      data: ArrayBuffer,
    ): Promise<ArrayBuffer> {
      const algorithmName =
        typeof algorithm === 'string' ? algorithm : algorithm.name;
      const serializedData = arrayBufferToHexString(data);

      const hexHash = await NativeModules.WindowCrypto.digest(
        algorithmName,
        serializedData,
      );
      return hexStringToByteArray(hexHash);
    },
    async generateKey(
      algorithm: Algorithm,
      extractable: boolean,
      keyUsages: string[],
    ): Promise<{
      privateKey: CryptoKey;
      publicKey: CryptoKey;
    }> {
      const { name, namedCurve } = algorithm;
      if (name !== 'ECDH' || namedCurve !== 'P-256') {
        throw new Error(
          'crypto.subtle.generateKey - unsuported algorithm type',
        );
      }
      const { privateKeyId, publicKeyId } = await NativeModules.WindowCrypto.generateKey();

      return {
        publicKey: {
          extractable,
          type: 'public',
          usages: keyUsages,
          id: publicKeyId,
        },
        privateKey: {
          extractable,
          type: 'private',
          usages: keyUsages,
          id: privateKeyId,
        },
      };
    },
    async exportKey(format: string, key: CryptoKey): Promise<ArrayBuffer> {
      const rawKey = await NativeModules.WindowCrypto.exportKey(key.id);
      return hexStringToByteArray(rawKey);
    },
    async importKey(
      format: string,
      keyData: Uint8Array,
      algorithm: Algorithm,
      extractable: boolean,
      usages: string[],
    ): Promise<CryptoKey> {
      const hexString = arrayBufferToHexString(keyData.buffer);
      const id = await NativeModules.WindowCrypto.importKey(hexString);
      return {
        extractable,
        usages,
        id,
      };
    },
  },
};

(async function test() {
  const { publicKey, privateKey } = await crypto.subtle.generateKey(
    { name: 'ECDH', namedCurve: 'P-256' },
    true,
    ['deriveKey'],
  );

  const rawPublicKey = await crypto.subtle.exportKey('raw', publicKey);
  const rawPublicKeyArray = new Uint8Array(rawPublicKey);
  console.warn('xxxx exported', rawPublicKeyArray);

  const publicKey2 = await crypto.subtle.importKey(
    'raw',
    rawPublicKeyArray,
    { name: 'ECDH', namedCurve: 'P-256' },
    false,
    [],
  );
  const rawPublicKey2 = await crypto.subtle.exportKey('raw', publicKey2);
  const rawPublicKeyArray2 = new Uint8Array(rawPublicKey2);
  console.warn('xxxx exported2', rawPublicKeyArray2);
})();

export const seedRandom = async () => {
  return randomPool.fetchEntropy(1024 * 64);
};
