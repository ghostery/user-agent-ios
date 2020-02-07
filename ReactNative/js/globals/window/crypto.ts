/* eslint-disable import/prefer-default-export */
import { NativeModules } from 'react-native';

function toHexString(buffer: ArrayBuffer) {
  return Array.prototype.map
    .call(new Uint8Array(buffer), x => `00${x.toString(16)}`.slice(-2))
    .join('');
}

function toByteArray(hexString: string): ArrayBuffer {
  const typedArray = new Uint8Array(
    (hexString.match(/[\da-f]{2}/gi) || []).map((h: string) => {
      return parseInt(h, 16);
    }),
  );
  return typedArray.buffer;
}

export const crypto = {
  subtle: {
    async digest(
      algorithm: string | { name: string },
      data: ArrayBuffer,
    ): Promise<ArrayBuffer> {
      const algorithmName =
        typeof algorithm === 'string' ? algorithm : algorithm.name;
      const serializedData = toHexString(data);

      const hexHash = await NativeModules.WindowCrypto.digest(
        algorithmName,
        serializedData,
      );
      return toByteArray(hexHash);
    },
  },
};
