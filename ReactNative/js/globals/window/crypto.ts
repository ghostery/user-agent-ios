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
  },
};

export const seedRandom = async () => {
  return randomPool.fetchEntropy(1024 * 64);
};
