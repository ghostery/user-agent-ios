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
  namedCurve?: string;
  public?: Uint8Array;
  length?: number;
  iv?: TypedArray;
  tagLength?: number;
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
      const {
        privateKeyId,
        publicKeyId,
      } = await NativeModules.WindowCrypto.generateKey();

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
    async deriveKey(
      algorithm: Algorithm,
      baseKey: Uint8Array,
      derivedKeyAlgorithm: Algorithm,
      extractable: boolean,
      keyUsages: string[],
    ): Promise<CryptoKey> {
      if (!algorithm.public) {
        throw new Error('new key');
      }
      const privateKeyHexString = arrayBufferToHexString(baseKey.buffer);
      const publicKeyHexString = arrayBufferToHexString(
        algorithm.public.buffer,
      );
      const id = await NativeModules.WindowCrypto.deriveKey(
        privateKeyHexString,
        publicKeyHexString,
      );
      return {
        extractable,
        usages: keyUsages,
        id,
      };
    },
    async encrypt(
      algorithm: Algorithm,
      key: CryptoKey,
      data: Uint8Array,
    ): Promise<ArrayBuffer> {
      if (!algorithm.iv) {
        throw new Error('No iv');
      }
      const dataHexString = arrayBufferToHexString(data.buffer);
      const ivHexString = arrayBufferToHexString(algorithm.iv);
      const encryptedDataHexString = await NativeModules.WindowCrypto.encrypt(
        key.id,
        ivHexString,
        dataHexString,
      );
      return hexStringToByteArray(encryptedDataHexString);
    },
    async decrypt(
      algorithm: Algorithm,
      key: CryptoKey,
      data: Uint8Array,
    ): Promise<ArrayBuffer> {
      if (!algorithm.iv) {
        throw new Error('No iv');
      }
      const hexString = arrayBufferToHexString(data.buffer);
      const dataHexString = hexString.slice(0, -8);
      const tagHexString = hexString.slice(-8);
      const ivHexString = arrayBufferToHexString(algorithm.iv);
      const encryptedDataHexString = await NativeModules.WindowCrypto.decrypt(
        key.id,
        ivHexString,
        tagHexString,
        dataHexString,
      );
      return hexStringToByteArray(encryptedDataHexString);
    },
  },
};

(async function test() {
  async function sha256(data) {
    return new Uint8Array(
      await crypto.subtle.digest({ name: 'SHA-256' }, data),
    );
  }

  function toUtf8(text) {
    return new TextEncoder().encode(text);
  }

  function fromUtf8(buffer) {
    return new TextDecoder().decode(buffer);
  }

  const {
    publicKey: bobPublic,
    privateKey: bobPrivate,
  } = await crypto.subtle.generateKey(
    { name: 'ECDH', namedCurve: 'P-256' },
    true,
    ['deriveKey'],
  );
  const {
    publicKey: alicePublic,
    privateKey: alicePrivate,
  } = await crypto.subtle.generateKey(
    { name: 'ECDH', namedCurve: 'P-256' },
    true,
    ['deriveKey'],
  );
  const bobPublicRaw = await crypto.subtle.exportKey('raw', bobPublic);
  const bobPublicArray = new Uint8Array(bobPublicRaw);
  const alicePrivateRaw = await crypto.subtle.exportKey('raw', alicePrivate);
  const alicePrivateArray = new Uint8Array(alicePrivateRaw);

  // testing import and export
  {
    console.warn('Bob public original', bobPublicArray);

    const bobPublicCopy = await crypto.subtle.importKey(
      'raw',
      bobPublicArray,
      { name: 'ECDH', namedCurve: 'P-256' },
      false,
      [],
    );
    const bobPublicCopyRaw = await crypto.subtle.exportKey(
      'raw',
      bobPublicCopy,
    );
    const bobPublicCopyArray = new Uint8Array(bobPublicCopyRaw);
    console.warn('Bob public imported', bobPublicCopyArray);
  }

  const aliceDerivedKey = await crypto.subtle.deriveKey(
    { name: 'ECDH', namedCurve: 'P-256', public: bobPublicArray },
    alicePrivateArray,
    { name: 'AES-GCM', length: 256 },
    true,
    ['encrypt', 'decrypt'],
  );
  const aliceDerivedKeyRaw = await crypto.subtle.exportKey(
    'raw',
    aliceDerivedKey,
  );
  const aliceDerivedKeyArray = new Uint8Array(aliceDerivedKeyRaw);
  console.warn('XXXX', aliceDerivedKeyArray.length);

  const raw128bitKey = (await sha256(aliceDerivedKeyArray)).subarray(0, 16);
  const secret = await crypto.subtle.importKey(
    'raw',
    raw128bitKey,
    { name: 'AES-GCM', length: 128 },
    false,
    ['encrypt', 'decrypt'],
  );
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const ciphertext = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv, tagLength: 128 },
    secret,
    toUtf8('hello world'),
  );
  const ciphertextArray = new Uint8Array(ciphertext);
  console.warn('encrypted', ciphertextArray.length);
  const decrypted = fromUtf8(
    await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv, tagLength: 128 },
      secret,
      ciphertextArray,
    ),
  );
  console.warn('decrypted', decrypted);
})();

export const seedRandom = async () => {
  return randomPool.fetchEntropy(1024 * 64);
};
