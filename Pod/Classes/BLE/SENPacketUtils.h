
#import <Foundation/Foundation.h>

struct SENStreamHeader {
    uint16_t data_length;
};
struct SENPacket {
    union {
        struct {
            /* We have sequence numbers from 0-255. This implies that the
             maximum payload we can send is 4824 bytes: 17 bytes in the
             header = 1 sequence number, plus 0 bytes in the footer (since
             the footer is entirely a checksum) = 2 sequence numbers, plus
             4807 bytes for the body (19 bytes per packet) = 255 sequence
             numbers. */
            uint8_t sequence_number;

            union {
                struct {
                    uint8_t packet_count;
                    uint8_t data[18];
                } header;

                struct {
                    uint8_t data[19];
                } body;

                struct {
                    uint8_t sha19[19]; // First 19 bytes of SHA-1.
                } footer;
            };
        } __attribute__((packed));

        uint8_t bytes[20];
    };
};
struct SENStreamFooter {
    uint8_t src_sha1[20];
};