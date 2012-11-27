//
//  CommonTypes.h
//  DinoLasers
//
//  Created by Paul Mans on 11/27/12.
//  Copyright (c) 2012 DinoLasers. All rights reserved.
//

#ifndef DinoLasers_CommonTypes_h
#define DinoLasers_CommonTypes_h

#define PERSISTENCE_MODES_SETTINGS_KEY @"PersistenceModesSettingsKey"

typedef enum PersistenceMode {
    PersistenceModeNone = 0,
    PersistenceModeUDP = 0x1,
    PersistenceModeLogFile = 0x2,
    PersistenceModeGameKit = 0x4
} PersistenceMode;

#endif
