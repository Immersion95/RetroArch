#ifndef RA_FRAME_TRACE_H
#define RA_FRAME_TRACE_H

#include <stdint.h>

enum ra_frame_trace_event
{
   RA_FT_FRAME_BEGIN,
   RA_FT_CORE_BEGIN,
   RA_FT_CORE_END,
   RA_FT_CORE_HZ_MILLI,
   RA_FT_VIDEO_BEGIN,
   RA_FT_VIDEO_END,
   RA_FT_INPUT_BEGIN,
   RA_FT_INPUT_END,
   RA_FT_JOYPAD_BEGIN,
   RA_FT_JOYPAD_END,
   RA_FT_INPUT_DEVICE_BEGIN,
   RA_FT_INPUT_DEVICE_END,
   RA_FT_INPUT_BESIDE_BEGIN,
   RA_FT_INPUT_BESIDE_END,
   RA_FT_AUDIO_BATCH_BEGIN,
   RA_FT_AUDIO_BATCH_END,
   RA_FT_AUDIO_ACCUM_BEGIN,
   RA_FT_AUDIO_ACCUM_END,
   RA_FT_INPUT_STATE_SLOW,
   RA_FT_FRAME_LIMIT_US,
   RA_FT_FAST_FORWARD,
   RA_FT_MENU_ENTER,
   RA_FT_MENU_EXIT,
   RA_FT_AUDIO_FRAME_END_BEGIN,
   RA_FT_AUDIO_FRAME_END_END
};

#if defined(RA_FRAME_DIAGNOSTIC_V3_1) && defined(_WIN32) \
      && !defined(_XBOX) && !defined(__WINRT__)
void ra_frame_trace_mark(enum ra_frame_trace_event event, int64_t value);
#else
#define ra_frame_trace_mark(event, value) ((void)0)
#endif

#endif
