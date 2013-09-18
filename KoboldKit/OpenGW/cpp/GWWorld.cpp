//
//  GWWorld.cpp
//  OpenGW
//
//  Created by Steffen Itterheim on 15.09.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#include "GWWorld.h"
#include "GWEntity.h"

GWWorld::GWWorld()
{
	
}

void GWWorld::addEntity(GWEntity* entity)
{
	_entities.push_back(entity);
}

