def main(input_file, output_file):
    with open(input_file, 'rb') as infile:
        with open(output_file, 'w') as outfile:
            line_count = 0
            while True:
                byte = infile.read(1)
                if not byte:
                    break
                binary_repr = format(ord(byte), '08b')
                outfile.write(binary_repr + '\n')
                line_count += 1

            while line_count < 64:
                outfile.write('0' * 8 + '\n')
                line_count += 1


if __name__ == "__main__":
    input_file = "text.txt"
    output_file = "text.bin"
    main(input_file, output_file)
