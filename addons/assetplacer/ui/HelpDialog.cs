// HelpDialog.cs
// Copyright (c) 2023 CookieBadger. All Rights Reserved.

#if TOOLS
#nullable disable
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Godot;

namespace AssetPlacer;

[Tool]
public partial class HelpDialog : AcceptDialog
{
	[Export] private NodePath _documentationButtonPath;
	[Export] private NodePath _issueButtonPath;
	private Button _documentationButton;
	private Button _issueButton;

	public void Init()
	{
		_documentationButton = GetNode<Button>(_documentationButtonPath);
		_issueButton = GetNode<Button>(_issueButtonPath);
		_documentationButton.Pressed += OpenDocumentation;
		_issueButton.Pressed += ReportIssue;
	}

	public void ApplyTheme(Control baseControl)
	{
		// Icons: Help (doc), ExternalLink,
		_documentationButton.Icon = baseControl.GetThemeIcon("Help", "EditorIcons");
		_issueButton.Icon = baseControl.GetThemeIcon("ExternalLink", "EditorIcons");
	}

	public void InitShortcutTable(Dictionary<string, string> shortcutStringDictionary)
	{
		GetNode<ShortcutTable>("%ShortcutsTable").Init(shortcutStringDictionary);
	}

	public void OpenDocumentation()
	{
		OpenUrl("https://cookiebadger.github.io/assetplacer-docs/");
	}

	public void ReportIssue()
	{
		OpenUrl("https://github.com/CookieBadger/assetplacer-docs/issues/new");
	}
	
	// thanks to https://stackoverflow.com/questions/4580263/how-to-open-in-default-browser-in-c-sharp
	private void OpenUrl(string url)
	{
		try
		{
			Process.Start(url);
		}
		catch
		{
			// hack because of this: https://github.com/dotnet/corefx/issues/10361
			if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
			{
				url = url.Replace("&", "^&");
				Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
			}
			else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
			{
				Process.Start("xdg-open", url);
			}
			else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
			{
				Process.Start("open", url);
			}
			else
			{
				throw;
			}
		}
	}
}
#endif
