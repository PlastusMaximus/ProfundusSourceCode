// HelpButton.cs
// Copyright (c) 2023 CookieBadger. All Rights Reserved.

#if TOOLS
#nullable disable
using Godot;

[Tool]
public partial class HelpButton : Button
{
	[Export] public NodePath helpPopupPath;

	private PopupPanel _helpPopup;
	
	
	public void Init()
	{
		_helpPopup = GetNode<PopupPanel>(helpPopupPath);
		Pressed += OnPressed;
	}

	private void OnPressed()
	{
		_helpPopup.Position = (Vector2I) GetViewportRect().GetCenter();
		_helpPopup.Popup();
		
	}
}
#endif
