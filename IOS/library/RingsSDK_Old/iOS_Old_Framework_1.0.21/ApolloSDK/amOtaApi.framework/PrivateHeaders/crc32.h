/*************************************************************************************************/
/*!
 *  \file   crc32.h
 *
 *  \brief  CRC-32 utilities.
 */
/*************************************************************************************************/
#ifndef CRC32_H
#define CRC32_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/*************************************************************************************************/
/*!
 *  \fn     CalcCrc32
 *        
 *  \brief  Calculate the CRC-32 of the given buffer.
 *
 *  \param  len   Length fo the buffer.
 *  \param  pBuf  Buffer to compute the CRC.
 *
 *  \return None.
 *
 *  This routine was originally generated with crcmod.py using the following parameters:
 *    - polynomial 0x104C11DB7
 *    - bit reverse algorithm
 */
/*************************************************************************************************/
uint32_t CalcCrc32(int32_t len, uint8_t *pBuf);
    
uint32_t crc32(int32_t len, uint8_t *pBuf);

#ifdef __cplusplus
};
#endif

#endif /* CRC32_H */
