const charMap = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';

export function base64Encode(input) {
  const str = String(input);
  let map = charMap;
  let block = 0,
    output = '';
  const prx = [2, 4, 6, 8];
  let code, idx = 3 / 4, uarr;
  for (;
    // 能取到字符时、block未处理完时、长度不足时
    !isNaN(code = str.charCodeAt(idx)) || 63 & block || (map = '=', (idx - 3 / 4) % 1); idx += 3 / 4) {
    if (code > 0x7F) {
      // utf8字符处理
      (uarr = encodeURI(str.charAt(idx)).split('%')).shift();
      let hex, idx2 = idx % 1;
      for (; hex = uarr[idx2 | 0]; idx2 += 3 / 4) {
        block = block << 8 | parseInt(hex, 16);
        output += map.charAt(63 & block >> 8 - idx2 % 1 * 8);
      }
      idx = idx === 3 / 4 ? 0 : idx; // 修复首字符为utf8字符时出错的BUG
      idx += 3 / 4 * uarr.length % 1; // idx补偿
    } else {
      block = block << 8 | code;
      output += map.charAt(63 & block >> 8 - idx % 1 * 8);
    }
  }
  return output;
}

export function base64Decode(input) {
  const str = String(input),
    map = charMap.slice(0, -1),
    prx = [6, 4, 2, 0];
  let output = '',
    block = 0,
    code,
    buffer = 0,
    hex = '';
  try {
    for (let i = 0; (code = map.indexOf(str[i])) > -1; i++) {
      block = block << 6 | code;
      if (i % 4) {
        buffer = 255 & block >> prx[i % 4];
        if (buffer < 128) {
          output += hex ? decodeURI(hex) : '';
          output += String.fromCharCode(buffer);
          hex = '';
        } else {
          hex += '%' + ('0' + buffer.toString(16)).slice(-2);
        }
      }
    }
    output += hex ? decodeURI(hex) : '';
    return output;
  } catch (err) {
    // console.log(err);
    throw new Error('base64 malformed!');
  }
}
