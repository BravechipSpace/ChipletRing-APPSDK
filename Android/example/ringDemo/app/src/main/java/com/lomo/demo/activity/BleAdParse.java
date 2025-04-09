package com.lomo.demo.activity;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.UUID;

public class BleAdParse {



    public static String byte2hex(byte[] b) {
        StringBuilder hs = new StringBuilder();
        String stmp;
        for (int i = 0; i < b.length; i++) {
            stmp = Integer.toHexString(b[i] & 0xFF).toUpperCase();
            if (stmp.length() == 1) {
                hs.append("0").append(stmp);
            } else {
                hs.append(stmp);
            }
        }
        return hs.toString();
    }


    public static ParsedAd parseScanRecodeData(ParsedAd parsedAd ,byte[] adv_data) {

        ByteBuffer buffer = ByteBuffer.wrap(adv_data).order(ByteOrder.LITTLE_ENDIAN);

        while (buffer.remaining() > 2) {

            byte length = buffer.get();

            if (length == 0)

                break;

            if (length>buffer.remaining())

                break;

            byte type = buffer.get();

            length -= 1;

            switch (type) {

                case 0x01: // Flags

                    parsedAd.flags = buffer.get();

                    length--;

                    break;

                case 0x02: // Partial list of 16-bit UUIDs

                case 0x03: // Complete list of 16-bit UUIDs

                case 0x14: // List of 16-bit Service Solicitation UUIDs

                    while (length >= 2) {

                        parsedAd.uuids.add(UUID.fromString(String.format(

                                "%08x-0000-1000-8000-00805f9b34fb", buffer.getShort())));

                        length -= 2;

                    }

                    break;

                case 0x04: // Partial list of 32 bit service UUIDs

                case 0x05: // Complete list of 32 bit service UUIDs

                    while (length >= 4) {

                        parsedAd.uuids.add(UUID.fromString(String.format(

                                "%08x-0000-1000-8000-00805f9b34fb", buffer.getInt())));

                        length -= 4;

                    }

                    break;

                case 0x06: // Partial list of 128-bit UUIDs

                case 0x07: // Complete list of 128-bit UUIDs

                case 0x15: // List of 128-bit Service Solicitation UUIDs

                    while (length >= 16) {

                        long lsb = buffer.getLong();

                        long msb = buffer.getLong();

                        UUID uuid=new UUID(msb, lsb);

                        parsedAd.uuids.add(uuid);

                        length -= 16;

                    }

                    break;

                case 0x08: // Short local device name

                case 0x09: // Complete local device name

                    byte sb[] = new byte[length];

                    buffer.get(sb, 0, length);

                    length = 0;

                    parsedAd.localName = new String(sb).trim();

                    break;

                case (byte) 0xFF: // Manufacturer Specific Data

                    byte sb2[] = new byte[length];

                    buffer.get(sb2, 0, length);

                    length = 0;

                    parsedAd.diyInfo = byte2hex(sb2);;

                    break;

                default: // skip

                    break;

            }

            if (length > 0) {

                if ((buffer.position()+length)<buffer.capacity()){

                    buffer.position(buffer.position() + length);

                }else {

                    buffer.position(buffer.capacity());

                }

            }

        }

        return parsedAd;

    }




}

