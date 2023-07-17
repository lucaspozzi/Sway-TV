//
//  Sway_Car.cpp
//  Sway Car
//
//  Created by Lucas Pozzi de Souza on 7/17/23.
//

#include <os/log.h>

#include <DriverKit/IOUserServer.h>
#include <DriverKit/IOLib.h>

#include "Sway_Car.h"

kern_return_t
IMPL(Sway_Car, Start)
{
    kern_return_t ret;
    ret = Start(provider, SUPERDISPATCH);
    os_log(OS_LOG_DEFAULT, "Hello World");
    return ret;
}
