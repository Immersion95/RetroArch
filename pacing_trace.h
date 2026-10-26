/* Optional, non-invasive Win32 QPC instrumentation for VRR investigations.
 * RA_PACING_TRACE=1 enables capture. No pacing logic is changed.
 * Counters are buffered in memory and written on normal process exit. */
#ifndef RA_PACING_TRACE_H
#define RA_PACING_TRACE_H

#include <stdint.h>

enum ra_pacing_event
{
   RA_PT_ITER_BEGIN = 1,
   RA_PT_CORE_BEGIN,
   RA_PT_CORE_END,
   RA_PT_AUDIO_FRAME_END_BEGIN,
   RA_PT_AUDIO_FRAME_END_END,
   RA_PT_VIDEO_BEGIN,
   RA_PT_FRAME_CALLBACK_BEGIN,
   RA_PT_FRAME_CALLBACK_END,
   RA_PT_VIDEO_END,
   RA_PT_DXGI_PRESENT_BEGIN,
   RA_PT_DXGI_PRESENT_END,
   RA_PT_VK_SWAP_BEGIN,
   RA_PT_VK_SWAP_END,
   RA_PT_VK_FENCE_BEGIN,
   RA_PT_VK_FENCE_END,
   RA_PT_ITER_AFTER_CORE,
   RA_PT_PACE_FACTS,
   RA_PT_PACE_SOURCES,
   RA_PT_CORE_HZ_MILLI,
   RA_PT_TIMER_REQUEST_US,
   RA_PT_TIMER_WAIT_BEGIN,
   RA_PT_TIMER_WAIT_END,
   RA_PT_TIMER_SPIN_BEGIN,
   RA_PT_TIMER_SPIN_END,
   RA_PT_FRAME_DELAY_BEGIN,
   RA_PT_FRAME_DELAY_END,
   RA_PT_DRIVER_WAIT_BEGIN,
   RA_PT_DRIVER_WAIT_END,
   RA_PT_AUDIO_DEV_WRITE_BEGIN,
   RA_PT_AUDIO_DEV_WRITE_END,
   RA_PT_AUDIO_PIPE_WAIT_US,
   RA_PT_NOWINDOW,
   RA_PT_VK_PRESENT_BEGIN,
   RA_PT_VK_PRESENT_END,
   RA_PT_VK_ACQUIRE_BEGIN,
   RA_PT_VK_ACQUIRE_END
};

#if defined(_WIN32) && !defined(_XBOX) && !defined(__WINRT__)
void ra_pacing_trace_next_frame(void);
void ra_pacing_trace_mark(enum ra_pacing_event event, int64_t value);
#else
#define ra_pacing_trace_next_frame() ((void)0)
#define ra_pacing_trace_mark(event, value) ((void)0)
#endif
#endif
