// ActionScript file
import flexmdi.containers.MDIWindow;

public var window:MDIWindow; 

private function init():void{
	this.window = parentApplication.wm.lastWindow;
}
private function lock():void{
	this.window.close();
	this.parentApplication.lock();
}