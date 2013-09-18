//
//  GWWorld.h
//  OpenGW
//
//  Created by Steffen Itterheim on 15.09.13.
//  Copyright (c) 2013 Steffen Itterheim. All rights reserved.
//

#ifndef __OpenGW__GWWorld__
#define __OpenGW__GWWorld__

#include <vector>
#include "GWTypes.h"

class GWEntity;

class GWWorld
{
public:
	GWWorld();
	
	void addEntity(GWEntity* entity);
	
protected:
private:
	typedef std::vector<GWEntity*> Entities;
	Entities _entities;
};

#endif /* defined(__OpenGW__GWWorld__) */
