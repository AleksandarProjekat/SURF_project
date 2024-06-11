from decimal import Decimal, getcontext

# Postavljanje preciznosti na 50 decimalnih mesta
getcontext().prec = 50

def decimal_to_binary(decimal_num):
    # Odvajanje celobrojnog i decimalnog dela
    integer_part = int(decimal_num)
    fractional_part = Decimal(decimal_num) - Decimal(integer_part)

    # Konvertovanje celobrojnog dela u binarni format
    integer_part_bin = bin(integer_part)[2:].zfill(30)
    if len(integer_part_bin) > 30:
        raise ValueError("Celobrojni deo je prevelik za 30 bita")

    # Konvertovanje decimalnog dela u binarni format
    fractional_part_bin = ""
    for _ in range(18):
        fractional_part *= 2
        bit = int(fractional_part)
        if bit == 1:
            fractional_part -= Decimal(bit)
            fractional_part_bin += '1'
        else:
            fractional_part_bin += '0'

    # Kombinovanje celobrojnog i decimalnog dela
    binary_result = integer_part_bin + fractional_part_bin
    return binary_result.zfill(48)

# Decimalni brojevi
decimal_numbers = [
    0.939411163330078125, 0.829029083251953125, 0.7316131591796875, 0.6456451416015625, 0.569782257080078125,
    0.50283050537109375, 0.443744659423828125, 0.391605377197265625, 0.34558868408203125, 0.304981231689453125,
    0.269145965576171875, 0.237518310546875, 0.2096099853515625, 0.184978485107421875, 0.163242340087890625,
    0.144062042236328125, 0.127132415771484375, 0.112194061279296875, 0.099010467529296875, 0.087375640869140625,
    0.07711029052734375, 0.068050384521484375, 0.06005096435546875, 0.052997589111328125, 0.0467681884765625,
    0.041271209716796875, 0.0364227294921875, 0.03214263916015625, 0.0283660888671875, 0.02503204345703125,
    0.022090911865234375, 0.01949310302734375, 0.01720428466796875, 0.0151824951171875, 0.013397216796875,
    0.011821746826171875, 0.010433197021484375, 0.00920867919921875, 0.00812530517578125, 0.007171630859375
]

for decimal_num in decimal_numbers:
    binary_result = decimal_to_binary(decimal_num)
    print(f"Decimalni: {decimal_num} -> Binarni: {binary_result}")
