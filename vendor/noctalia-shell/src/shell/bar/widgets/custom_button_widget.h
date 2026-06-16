#pragma once

#include "shell/bar/widget.h"

#include <string>

class Glyph;
class Image;
class InputArea;
class Label;

class CustomButtonWidget : public Widget {
public:
  CustomButtonWidget(
      std::string glyph, std::string label, std::string tooltip, std::string command, std::string rightCommand,
      std::string middleCommand, std::string scrollUpCommand, std::string scrollDownCommand,
      std::string logoPath = "", bool customImageColorize = false
  );

  void create() override;
  [[nodiscard]] bool reservesMiddleClick() const noexcept override;

private:
  void doLayout(Renderer& renderer, float containerWidth, float containerHeight) override;
  void executeCommand(const std::string& command) const;
  void refreshCustomImageTint();

  std::string m_glyphName;
  std::string m_labelText;
  std::string m_tooltip;
  std::string m_command;
  std::string m_rightCommand;
  std::string m_middleCommand;
  std::string m_scrollUpCommand;
  std::string m_scrollDownCommand;
  std::string m_logoPath;
  bool m_customImageColorize = false;
  InputArea* m_area = nullptr;
  Glyph* m_glyph = nullptr;
  Image* m_image = nullptr;
  Label* m_label = nullptr;
};
