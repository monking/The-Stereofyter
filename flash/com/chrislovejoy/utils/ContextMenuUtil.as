package com.chrislovejoy.utils
{
	import flash.display.InteractiveObject;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	public class ContextMenuUtil
	{
		public static function setContextMenu(object:InteractiveObject, items:Array, hideBuiltIn:Boolean = false):void {
			var contextMenu:ContextMenu = new ContextMenu();
			hideBuiltIn && contextMenu.hideBuiltInItems();
			for each(var data:Object in items) {
				var item:ContextMenuItem = new ContextMenuItem(data.caption, false, !!data.action);
				if (data.action) {
					item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, data.action);
				}
				contextMenu.customItems.push(item);
			}
			object.contextMenu = contextMenu;
		}
	}
}