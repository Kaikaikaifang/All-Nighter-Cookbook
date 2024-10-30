# 要求：编程实现一个 ASN.1 BER 编码器，要求：
#   - 支持 OCTET String、Integer、Boolean、Sequence 这几种基本类型
#   - 编程语言不限（c、c++、Python、Java ...均可）
#   - 程序启动后，用户输入 “类型,值”，程序输出输出编码结果（十六进制显示）。
#      类型定义：OCTET String=1，Integer=2，Boolean=3，Sequence=4，例如：
#      * 用户输入 1,abc  说明是要编码 abc 这个字符串，因此输出为：04 03 61 62 63
#      * 用户输入 2,125  说明要编码 125 这个整数值，因此输出为 02 01 7D
#      * 用户输入 3,true 说明要编码 true 这个 Boolean 值，因此输出为：01 01 FF
#      * 用户输入 4,(1,xyz;2,28;3,true) 说明要编码一个 Sequence，此 Sequence 中包含了三个值：
#          “1,xyz” 说明是字符串 xyz
#          “2,28” 说明是整数 28
#          “3,false” 说明是 Boolean 值 false
#         因此输出为：30 80 04 03 78 79 7A 02 01 1C 01 01 00 00 00

import binascii

def encode_octet_string(value):
    encoded_value = value.encode()
    length = len(encoded_value)
    hex_value = binascii.hexlify(encoded_value).decode().upper()
    formatted_hex_value = ' '.join(hex_value[i:i+2] for i in range(0, len(hex_value), 2))
    return f'04 {length:02X} {formatted_hex_value}'

def encode_integer(value):
    integer = int(value)
    if integer < 128:
        return f'02 01 {integer:02X}'
    else:
        hex_value = f'{integer:X}'
        length = len(hex_value) // 2
        return f'02 {length:02X} ' + hex_value

def encode_boolean(value):
    return '01 01 FF' if value.lower() == 'true' else '01 01 00'

def encode_sequence(value):
    elements = value.strip('()').split(';')
    encoded_elements = []
    for element in elements:
        type_, val = element.split(',')
        encoded_elements.append(encode_value(type_, val))
    encoded_sequence = ''.join(encoded_elements).replace(' ', '')
    formatted_sequence = ' '.join(encoded_sequence[i:i+2] for i in range(0, len(encoded_sequence), 2))
    length = len(encoded_sequence) // 2
    return f'30 80 {formatted_sequence} 00 00'

def encode_value(type_, value):
    if type_ == '1':
        return encode_octet_string(value)
    elif type_ == '2':
        return encode_integer(value)
    elif type_ == '3':
        return encode_boolean(value)
    elif type_ == '4':
        return encode_sequence(value)
    else:
        raise ValueError('Unsupported type')

def main():
    print("ASN.1 BER Encoder")
    print("Supported types: OCTET String=1, Integer=2, Boolean=3, Sequence=4")
    print("Enter 'exit' to quit the program.")
    while True:
        user_input = input('Enter type and value (e.g., 1,abc): ')
        if user_input.lower() == 'exit':
            break
        try:
            type_, value = user_input.split(',', 1)
            encoded_result = encode_value(type_, value.strip())
            print(encoded_result)
        except Exception as e:
            print(f'Error: {e}')

if __name__ == '__main__':
    main()
