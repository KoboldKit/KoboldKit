/* see http://mjtsai.com/blog/2006/07/15/cocoa-foreach-macro/
 * You must set the "C Language Dialect" in Xcode to C99
 */
#define foreachGetEnumerator(c) \
	([c respondsToSelector:@selector(objectEnumerator)] ? \
	 [c objectEnumerator] : \
	 c)
#define foreachGetIMP(e) \
	[foreachEnum methodForSelector : @selector(nextObject)]
#define foreachCallIMP(imp, e) \
	((IMP)imp)(e, @selector(nextObject))
#define foreachGetFirst(imp, e) \
	(e ? foreachCallIMP(imp, e) : nil)
#define foreach(object, collection) \
	for (id foreachCollection = collection, \
		 foreachEnum = foreachGetEnumerator(foreachCollection), \
		 foreachIMP = (id)foreachGetIMP(foreachEnum), \
		 object = foreachGetFirst(foreachIMP, foreachEnum); \
		 object; \
		 object = foreachCallIMP(foreachIMP, foreachEnum))
#define foreacht(type, object, collection) \
	for (type foreachCollection = (id)collection, \
		 * foreachEnum = (id)foreachGetEnumerator((id)foreachCollection), \
		 * foreachIMP = (id)foreachGetIMP((id)foreachEnum), \
		 * object = foreachGetFirst(foreachIMP, foreachEnum); \
		 object; \
		 object = foreachCallIMP(foreachIMP, foreachEnum))
