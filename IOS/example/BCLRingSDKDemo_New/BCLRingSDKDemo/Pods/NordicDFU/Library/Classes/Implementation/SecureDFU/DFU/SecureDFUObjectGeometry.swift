/*
* Copyright (c) 2019, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

/**
 Pure, dependency-free arithmetic for splitting a Secure DFU firmware into
 objects and mapping peripheral-reported byte offsets onto those objects.

 In Secure DFU the firmware is transferred as a sequence of *objects*, each at
 most `maxObjectLength` bytes long (the last one may be shorter). This type owns
 only the arithmetic — it never touches CoreBluetooth — so the object geometry,
 including the offset/resume edge cases that used to crash `SecureDFUExecutor`,
 can be unit tested in isolation from the transport.
 */
internal enum SecureDFUObjectGeometry {

    /**
     Splits a firmware of `dataSize` bytes into consecutive object ranges of at
     most `maxObjectLength` bytes each.

     Example: `dataSize: 5000, maxObjectLength: 4096` → `[0 ..< 4096, 4096 ..< 5000]`.

     - parameters:
       - dataSize:        The total number of firmware bytes. Must be `> 0`.
       - maxObjectLength: The maximum object length reported by the peripheral.
                          Must be `> 0`.
     - returns: Consecutive, non-overlapping ranges covering `0 ..< dataSize`.
     */
    static func ranges(dataSize: Int, maxObjectLength maxLen: Int) -> [Range<Int>] {
        var totalLength = dataSize
        var ranges: [Range<Int>] = []
        ranges.reserveCapacity((totalLength + maxLen - 1) / maxLen)

        var partIdx = 0
        while totalLength > 0 {
            if totalLength > maxLen {
                ranges.append(partIdx * maxLen ..< partIdx * maxLen + maxLen)
                totalLength -= maxLen
            } else {
                ranges.append(partIdx * maxLen ..< partIdx * maxLen + totalLength)
                totalLength = 0
            }
            partIdx += 1
        }
        return ranges
    }

    /**
     Maps a peripheral-reported byte `offset` onto the index of the object that
     contains it.

     The result is clamped to the last object, so an offset equal to (or beyond)
     the firmware size — i.e. the peripheral reporting the whole firmware as
     already received — maps to the last object rather than one past the end.
     Without the clamp such an offset produced an out-of-range index and crashed
     `createDataObject(_:)`.

     - parameters:
       - offset:          The byte offset reported by the peripheral. Must be `>= 0`.
       - maxObjectLength: The maximum object length. Must be `> 0`.
       - objectCount:     The number of objects (`ranges(...).count`). Must be `> 0`.
     - returns: A valid index in `0 ..< objectCount`.
     */
    static func objectIndex(forOffset offset: Int, maxObjectLength maxLen: Int,
                            objectCount: Int) -> Int {
        return min(offset / maxLen, objectCount - 1)
    }

    /**
     The sub-range of `objectRange` that still needs sending when resuming from
     `resumeOffset`; the bytes `objectRange.lowerBound ..< resumeOffset` were sent
     before.

     - parameters:
       - objectRange:  The full range of the object being resumed.
       - resumeOffset: The offset to resume from. Must lie within `objectRange`.
     - returns: `resumeOffset ..< objectRange.upperBound`.
     */
    static func resumeRange(of objectRange: Range<Int>, from resumeOffset: Int) -> Range<Int> {
        return resumeOffset ..< objectRange.upperBound
    }
}
