# UI Design & Aesthetics Manifesto

## 1. Visual Hierarchy
- **Typography**: Use Google Fonts (Inter, Outfit, Playfair Display). Establish clear scale (h1, h2, p).
- **Contrast**: High contrast for readability, subtle contrast for depth (shadows, glassmorphism).

## 2. Color Theory
- **Avoid Defaults**: Never use `red`, `blue`, `green`. Use HSL variables.
- **Dark Mode First**: Design for sleek dark environments with vibrant accent colors (neon blues, soft purples).
- **Gradients**: Use mesh gradients or subtle linear gradients for backgrounds.

## 3. Interaction Design
- **Hover Effects**: Every button/link must have a distinct hover state (scale, glow, color shift).
- **Transitions**: Use `transitition: all 0.3s ease;` as a baseline.
- **Feedback**: Loading states, success checkmarks, and error tremors.

## 4. Layout
- **Grid System**: Use CSS Grid and Flexbox for rock-solid responsiveness.
- **Whitespace**: Give elements room to breathe. 16px-24px padding is the minimum for containers.

## 5. Components
- **Buttons**: Rounded corners (8px-12px), subtle shadows, clear labels.
- **Cards**: Glassmorphism (`backdrop-filter: blur(10px)`), thin borders (1px solid rgba(255,255,255,0.1)).
- **Inputs**: Glowing focus states, clear error messages.
