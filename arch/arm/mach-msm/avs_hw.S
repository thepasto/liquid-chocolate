/*
 * Copyright (c) 2009, Code Aurora Forum. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of Code Aurora Forum nor
 *       the names of its contributors may be used to endorse or promote
 *       products derived from this software without specific prior written
 *       permission.
 *
 * Alternatively, provided that this notice is retained in full, this software
 * may be relicensed by the recipient under the terms of the GNU General Public
 * License version 2 ("GPL") and only version 2, in which case the provisions of
 * the GPL apply INSTEAD OF those given above.  If the recipient relicenses the
 * software under the GPL, then the identification text in the MODULE_LICENSE
 * macro must be changed to reflect "GPLv2" instead of "Dual BSD/GPL".  Once a
 * recipient changes the license terms to the GPL, subsequent recipients shall
 * not relicense under alternate licensing terms, including the BSD or dual
 * BSD/GPL terms.  In addition, the following license statement immediately
 * below and between the words START and END shall also then apply when this
 * software is relicensed under the GPL:
 *
 * START
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License version 2 and only version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * END
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

	.text

	.global avs_test_delays
.fpu neon
avs_test_delays:

/*      Read r1=CPMR and enable Never Sleep for VSLPDLY */
		mrc  p15, 7, r1, c15, c0, 5
		orr  r12, r1, #3, 24
		mcr  p15, 7, r12, c15, c0, 5

/*      Read r2=CPACR and enable full access to CP10 and CP11 space */
		mrc p15, 0, r2, c1, c0, 2
		orr r12, r2, #(0xf << 20)
		mcr p15, 0, r12, c1, c0, 2
		isb

/*      Read r3=FPEXC and or in FP enable, VFP/ASE enable = FPEXC[30]; */
		fmrx r3, fpexc
		orr  r12, r3, #1, 2
		fmxr fpexc, r12

/*
 *      Do floating-point operations to prime the VFP pipeline.   Use
 *      fcpyd d0, d0 as a floating point nop.  This avoids changing VFP
 *      state.
 */
		fcpyd d0, d0
		fcpyd d0, d0
		fcpyd d0, d0

/*      Read r0=AVSCSR to get status from CPU, VFP, and L2 ring oscillators */
		mrc p15, 7, r0, c15, c1, 7

/*      Restore FPEXC */
		fmxr fpexc, r3

/*      Restore CPACR */
                MCR p15, 0, r2, c1, c0, 2

/*      Restore CPMR */
		mcr p15, 7, r1, c15, c0, 5
                isb

		bx lr




	.global avs_get_avscsr
/*      Read r0=AVSCSR to get status from CPU, VFP, and L2 ring oscillators */

avs_get_avscsr:
		mrc p15, 7, r0, c15, c1, 7
                bx lr

        .global avs_get_avsdscr
/*      Read r0=AVSDSCR to get the AVS Delay Synthesizer control settings */

avs_get_avsdscr:
		mrc p15, 7, r0, c15, c0, 6
                bx lr




	.global avs_get_tscsr
/*      Read r0=TSCSR to get temperature sensor control and status */

avs_get_tscsr:
		mrc p15, 7, r0, c15, c1, 0
                bx lr

        .global avs_set_tscsr
/*      Write TSCSR=r0 to set temperature sensor control and status  */

avs_set_tscsr:
		mcr p15, 7, r0, c15, c1, 0
                bx lr





	.global avs_reset_delays
avs_reset_delays:

/*      AVSCSR(0x61) to enable CPU, V and L2 AVS module  */
		mov r3, #0x61
		mcr p15, 7, r3, c15, c1, 7

/*      AVSDSCR(dly) to program delay */
		mcr p15, 7, r0, c15, c0, 6

/*      Read r0=AVSDSCR */
		mrc p15, 7, r0, c15, c0, 6

	bx lr

	.end


