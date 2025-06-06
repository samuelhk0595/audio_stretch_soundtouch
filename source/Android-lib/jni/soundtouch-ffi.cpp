#include <jni.h>
#include <android/log.h>
#include <stdexcept>
#include <string>

using namespace std;

#include "../../../include/SoundTouch.h"

#define DLL_PUBLIC __attribute__ ((visibility ("default")))

using namespace soundtouch;

typedef struct {
    uint32_t dwMagic;
    SoundTouch *pst;
} STHANDLE;

#define STMAGIC  0x1770C001

extern "C" {

DLL_PUBLIC void* soundtouch_createInstance() {
    STHANDLE *tmp = new STHANDLE;
    if (tmp) {
        tmp->dwMagic = STMAGIC;
        tmp->pst = new SoundTouch();
        if (tmp->pst == nullptr) {
            delete tmp;
            tmp = nullptr;
        }
    }
    return (void*)tmp;
}

DLL_PUBLIC void soundtouch_destroyInstance(void* h) {
    STHANDLE *sth = (STHANDLE*)h;
    if (sth->dwMagic != STMAGIC) return;
    sth->dwMagic = 0;
    if (sth->pst) delete sth->pst;
    sth->pst = nullptr;
    delete sth;
}

DLL_PUBLIC void soundtouch_setTempo(void* h, float newTempo) {
    STHANDLE *sth = (STHANDLE*)h;
    if (sth->dwMagic != STMAGIC) return;
    sth->pst->setTempo(newTempo);
}

DLL_PUBLIC void soundtouch_putSamples(void* h, float *samples, int numSamples) {
    STHANDLE *sth = (STHANDLE*)h;
    if (sth->dwMagic != STMAGIC) return;
    sth->pst->putSamples(samples, numSamples);
}

DLL_PUBLIC int soundtouch_receiveSamples(void* h, float *outBuffer, int maxSamples) {
    STHANDLE *sth = (STHANDLE*)h;
    if (sth->dwMagic != STMAGIC) return 0;
    return (int)sth->pst->receiveSamples(outBuffer, maxSamples);
}

DLL_PUBLIC const char* soundtouch_getVersionString() {
    return SoundTouch::getVersionString();
}

DLL_PUBLIC unsigned int soundtouch_getVersionId() {
    return SoundTouch::getVersionId();
}

DLL_PUBLIC void soundtouch_setSampleRate(void* h, unsigned int srate) {
    STHANDLE *sth = (STHANDLE*)h;
    if (sth->dwMagic != STMAGIC) return;
    sth->pst->setSampleRate(srate);
}

DLL_PUBLIC void soundtouch_setChannels(void* h, unsigned int numChannels) {
    STHANDLE *sth = (STHANDLE*)h;
    if (sth->dwMagic != STMAGIC) return;
    sth->pst->setChannels(numChannels);
}

} // extern "C"
