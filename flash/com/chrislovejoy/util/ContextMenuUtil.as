package com.chrislovejoy.util
{
	import flash.display.InteractiveObject;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.events.ContextMenuEvent;

	public class ContextMenuUtil
	{
		public static function setContextMenu(object:InteractiveObject, items:Array):void {
			var contextMenu:ContextMenu = new ContextMenu();
			contextMenu.hideBuiltInItems();
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